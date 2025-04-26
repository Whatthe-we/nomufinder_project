# main.py (OpenAI Embedding 사용 버전)
import uvicorn
from fastapi import FastAPI, HTTPException
import os
import threading
import time
import traceback
from dotenv import load_dotenv
import pickle
import json

# --- Firebase Admin SDK ---
import firebase_admin
from firebase_admin import credentials, db

# --- LangChain & RAG 관련 ---
from langchain_openai import ChatOpenAI, OpenAIEmbeddings # <<< OpenAIEmbeddings 추가
# from langchain_community.embeddings import HuggingFaceEmbeddings # <<< HuggingFace 제거 또는 주석 처리
from langchain_community.vectorstores import FAISS
from langchain.chains import RetrievalQA
from langchain.prompts import PromptTemplate
from langchain_community.retrievers import BM25Retriever
from langchain.retrievers import EnsembleRetriever
# import torch # OpenAI Embedding 사용 시 torch 직접 필요 없음 (FAISS 내부 의존성 가능성은 있음)

# --- .env 파일 로드 ---
load_dotenv()

# === 전역 변수 ===
qa_chain = None
firebase_app = None
is_initialized = False
processed_question_ids = set()  # ✅ 이미 처리한 질문 ID 저장
startup_time = int(time.time())  # ✅ 서버 시작 시간 기록

# === 설정값 ===
FAISS_INDEX_PATH = "faiss_index_nomu_final"
BM25_DATA_PATH = "split_texts_for_bm25.pkl"
FIREBASE_SERVICE_ACCOUNT_KEY = "serviceAccountKey.json"

# ===> 모델 설정 수정 <===
EMBEDDING_MODEL_NAME = "text-embedding-3-large" # OpenAI 임베딩 모델
LLM_MODEL_NAME = "gpt-4.1"                      # ✅ 사용할 LLM 모델
# =====================

# Firebase 설정 (환경 변수에서 로드)
FIREBASE_DB_URL = os.getenv("FIREBASE_DATABASE_URL")
if not FIREBASE_DB_URL:
    print("!! [치명적 오류] .env 파일에서 FIREBASE_DATABASE_URL을 찾을 수 없습니다. 앱 실행 불가.")
FIREBASE_QUESTIONS_PATH = "/chat_questions"
FIREBASE_ANSWERS_PATH = "/chat_answers"
QUESTION_LOG_PATH = "chat_log.json"

# Retriever 설정값
FAISS_K = 6
BM25_K = 6
ENSEMBLE_WEIGHTS = [0.7, 0.3] # BM25=0.7, FAISS=0.3

# === FastAPI 앱 인스턴스 ===
app = FastAPI()

# === ✅ 질문 재처리 ===
PROCESSED_IDS_JSON_PATH = "processed_ids.json"
PROCESSED_IDS_BACKUP_PATH = "processed_ids_backup.json"
MAX_PROCESSED_IDS = 100

def load_processed_ids():
    global processed_question_ids
    if os.path.exists(PROCESSED_IDS_JSON_PATH):
        with open(PROCESSED_IDS_JSON_PATH, "r", encoding="utf-8") as f:
            processed_question_ids = set(json.load(f))
        print(f"✅ 처리된 ID {len(processed_question_ids)}개 로드됨")
    else:
        processed_question_ids = set()

def save_processed_id(question_id):
    global processed_question_ids

    processed_question_ids.add(question_id)
    # 🔄 최대 개수 초과 시 백업 + 정리
    if len(processed_question_ids) > MAX_PROCESSED_IDS:
        print(f"📦 최대 {MAX_PROCESSED_IDS}개 초과됨 → 백업 및 정리 수행")
        all_ids = sorted(list(processed_question_ids))
        # ✅ 백업 (전체 저장)
        with open(PROCESSED_IDS_BACKUP_PATH, "w", encoding="utf-8") as f_backup:
            json.dump(all_ids, f_backup, ensure_ascii=False, indent=2)
        # 최신 MAX 개수만 유지
        processed_question_ids = set(all_ids[-MAX_PROCESSED_IDS:])
    # ✍️ 최종 저장
    with open(PROCESSED_IDS_JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(list(processed_question_ids), f, ensure_ascii=False, indent=2)

def log_question_answer_pair(question_id, question, answer):
    log_entry = {
        "id": question_id,
        "question": question,
        "answer": answer,
        "timestamp": int(time.time())
    }
    if os.path.exists(QUESTION_LOG_PATH):
        with open(QUESTION_LOG_PATH, "r", encoding="utf-8") as f:
            logs = json.load(f)
    else:
        logs = []
    logs.append(log_entry)
    with open(QUESTION_LOG_PATH, "w", encoding="utf-8") as f:
        json.dump(logs, f, ensure_ascii=False, indent=2)

# === RAG 파이프라인 초기화 함수 ===
def initialize_rag():
    global qa_chain, is_initialized
    if is_initialized:
        print("[정보] RAG 파이프라인 이미 초기화됨.")
        return

    print("--- RAG 파이프라인 초기화 시작 ---")
    vectorstore = None
    split_texts = None
    retriever = None
    llm = None
    embeddings = None # OpenAIEmbeddings 객체를 담을 변수

    try:
        # 1. OpenAI API 키 확인 (LLM 및 Embedding 모두 사용)
        openai_api_key = os.getenv("OPENAI_API_KEY")
        if not openai_api_key:
            raise ValueError("환경 변수에서 OPENAI_API_KEY를 찾을 수 없습니다.")

        # ===> 1. 임베딩 모델 로드 (OpenAIEmbeddings 사용) <===
        print(f"임베딩 모델 로딩 중 ({EMBEDDING_MODEL_NAME})...")
        embeddings = OpenAIEmbeddings(
            model=EMBEDDING_MODEL_NAME,
            openai_api_key=openai_api_key
            # 필요시 추가 파라미터 설정 (e.g., chunk_size for batching)
        )
        print("OpenAI 임베딩 모델 준비 완료.")
        # =============================================

        # ===> 2. FAISS 인덱스 로드 <===
        # !! 중요 !! 이 인덱스는 반드시 OpenAIEmbeddings(text-embedding-ada-002)로
        # !!      생성된 것이어야 합니다 !!
        print(f"FAISS 인덱스 로딩 중 ({FAISS_INDEX_PATH})...")
        if not os.path.isdir(FAISS_INDEX_PATH):
            raise FileNotFoundError(f"FAISS 인덱스 폴더({FAISS_INDEX_PATH})를 찾을 수 없습니다. OpenAI 임베딩으로 인덱스를 다시 생성해야 합니다.")
        try:
            vectorstore = FAISS.load_local(
                FAISS_INDEX_PATH,
                embeddings, # OpenAIEmbeddings 객체 전달
                allow_dangerous_deserialization=True
            )
            print(f"FAISS 인덱스 로드 완료 ({vectorstore.index.ntotal} 벡터).")
            print("   ⚠️ 경고: 로드된 FAISS 인덱스가 반드시 OpenAI 임베딩 모델로 생성되었는지 확인하세요!")
        except Exception as faiss_load_e:
             print(f"!! [오류] FAISS 인덱스 로드 실패: {faiss_load_e}")
             print("   인덱스가 손상되었거나, 잘못된 임베딩 모델로 생성되었을 수 있습니다.")
             print("   OpenAI 임베딩 모델로 FAISS 인덱스를 다시 생성해야 합니다.")
             raise faiss_load_e # 초기화 중단

        # ==========================

        # 2.5 BM25용 데이터 로드 (기존과 동일)
        print(f"BM25용 데이터 로딩 중 ({BM25_DATA_PATH})...")
        if not os.path.exists(BM25_DATA_PATH):
             print(f"⚠️ 경고: BM25 데이터 파일({BM25_DATA_PATH}) 없음. FAISS만 사용.")
             split_texts = None
        else:
             try:
                 with open(BM25_DATA_PATH, 'rb') as f:
                     split_texts = pickle.load(f)
                 print(f"BM25용 데이터 로드 완료 ({len(split_texts)}개 청크).")
             except Exception as e_pickle:
                 print(f"!! [오류] BM25 데이터 로드 실패: {e_pickle}")
                 split_texts = None

        # 3. Retriever 설정 (하이브리드 적용 - 기존과 동일)
        print("Retriever 설정 중...")
        if vectorstore:
            faiss_retriever = vectorstore.as_retriever(search_kwargs={'k': FAISS_K})
            print(f"- Dense Retriever (FAISS) 설정 완료 (k={FAISS_K}).")
            if split_texts:
                try:
                    bm25_retriever = BM25Retriever.from_documents(split_texts)
                    bm25_retriever.k = BM25_K
                    print(f"- Sparse Retriever (BM25) 설정 완료 (k={BM25_K}).")
                    ensemble_retriever = EnsembleRetriever(
                        retrievers=[bm25_retriever, faiss_retriever],
                        weights=ENSEMBLE_WEIGHTS
                    )
                    retriever = ensemble_retriever
                    print(f"- Ensemble Retriever 설정 완료 (Weights: BM25={ENSEMBLE_WEIGHTS[0]}, FAISS={ENSEMBLE_WEIGHTS[1]}).")
                except Exception as e_ensemble:
                    print(f"!! BM25/Ensemble 설정 실패: {e_ensemble}. FAISS Retriever만 사용.")
                    retriever = faiss_retriever
            else:
                print("⚠️ BM25 데이터 없어 Dense Retriever(FAISS)만 사용합니다.")
                retriever = faiss_retriever
        else:
            raise ValueError("FAISS VectorStore 로드 실패. Retriever 설정 불가.")

        # 4. LLM 로드 (OpenAI - 기존과 동일)
        print(f"LLM 로딩 중 ({LLM_MODEL_NAME})...")
        llm = ChatOpenAI(model_name=LLM_MODEL_NAME, temperature=0.1, openai_api_key=openai_api_key)
        print("LLM 로드 완료.")

        # 5. RAG Chain 구축 (기존과 동일)
        print("RAG Chain 구축 중...")
        template = """주어진 '컨텍스트' 정보만을 사용하여 '질문'에 답변하십시오. 한국어로 답변해주세요.
        컨텍스트에 답변이 없으면 "제공된 문서 내용만으로는 답변할 수 없습니다."라고 답변하세요.
        컨텍스트: {context}
        질문: {question}
        답변:"""
        QA_CHAIN_PROMPT = PromptTemplate.from_template(template)

        if not retriever: raise ValueError("Retriever 객체가 성공적으로 생성되지 않았습니다.")
        if not llm: raise ValueError("LLM 객체가 성공적으로 생성되지 않았습니다.")

        global qa_chain # 전역 변수 할당 명시
        qa_chain = RetrievalQA.from_chain_type(
            llm=llm,
            chain_type="stuff",
            retriever=retriever,
            return_source_documents=True,
            chain_type_kwargs={"prompt": QA_CHAIN_PROMPT}
        )
        is_initialized = True
        print("[성공] RAG 파이프라인 초기화 완료.")

    except Exception as e:
        print(f"!! [오류] RAG 파이프라인 초기화 실패: {e}")
        traceback.print_exc()
        qa_chain = None
        is_initialized = False

# --- ✅ Firebase 리스너 콜백 함수 ---
def firebase_listener_callback(event):
    print(f"\n--- Firebase 이벤트 감지 ---")
    print(f"  이벤트 타입: {event.event_type}, 경로: {event.path}")

    # 여러 질문 (초기 전체 로딩 시 발생)
    if event.path == "/" and isinstance(event.data, dict):
        print("📦 루트에서 여러 질문을 동시에 감지함.")
        for question_id, question_data in event.data.items():
            if isinstance(question_data, dict) and "query" in question_data:
                handle_single_question(question_id, question_data)
        return

    # 단일 질문 감지
    if event.event_type == 'put' and event.data:
        if isinstance(event.data, dict) and "query" in event.data:
            question_id = event.path.strip("/").split("/")[-1]
            handle_single_question(question_id, event.data)
            return

    print(f"⚠️ 무시된 이벤트 또는 query 없음: {event.path}, 데이터: {event.data}")

def handle_single_question(question_id, question_data):
    global qa_chain, processed_question_ids

    question_time = question_data.get("timestamp", 0)
    if question_id in processed_question_ids:
        print(f"⚠️ 이미 처리된 질문: {question_id} → 스킵함")
        return

    query = question_data.get("query", "").strip()
    if not query:
        print(f"⚠️ 질문 내용이 비어있음: {question_id}")
        return

    try:
        print(f"  ✅ 유효한 질문 감지됨: {query} (ID: {question_id})")
        print("  RAG 답변 생성 시도...")
        start_time = time.time()
        result = qa_chain.invoke({"query": query})
        end_time = time.time()
        answer = result.get("result", "오류: 답변 생성 실패")
        print(f"  답변 생성 완료 ({end_time - start_time:.2f}초). 답변: {answer[:50]}...")

        source_info = []
        source_documents = result.get("source_documents", [])
        if source_documents:
            source_info = [
                {"content": doc.page_content[:100]+"...", "metadata": {k: str(v)[:50] for k, v in doc.metadata.items()}}
                for doc in source_documents[:2]
            ]

        db.reference(f"{FIREBASE_ANSWERS_PATH}/{question_id}").set({
            "answer": answer,
            "timestamp": int(time.time()),
            "sources": source_info,
        })
        print(f"  Firebase '{FIREBASE_ANSWERS_PATH}/{question_id}' 경로에 답변 저장 완료.")

        save_processed_id(question_id)  # ✅ 여기서 저장해야 진짜 "성공적으로 처리된 질문"임
        log_question_answer_pair(question_id, query, answer)  # ✅ 질문답변 json 저장

    except Exception as e:
        print(f"!! RAG 처리 실패: {e}")
        traceback.print_exc()
        try:
            db.reference(f"{FIREBASE_ANSWERS_PATH}/{question_id}").set({
                "error": f"{type(e).__name__}: {str(e)[:200]}",
                "timestamp": int(time.time())
            })
        except Exception as db_err:
            print(f"!! Firebase 오류 기록 실패: {db_err}")

# === FastAPI 시작 이벤트 핸들러 ===
@app.on_event("startup")
async def startup_event_handler():
    global firebase_app
    print("--- FastAPI Application Startup ---")
    load_processed_ids()  # 🔥 이 줄 추가

    initialize_rag() # RAG 파이프라인 초기화 먼저 시도

    if not FIREBASE_DB_URL: print("!! [치명적 오류] FIREBASE_DATABASE_URL 환경 변수가 설정되지 않았습니다. Firebase 리스너 시작 불가."); return
    if not os.path.exists(FIREBASE_SERVICE_ACCOUNT_KEY): print(f"!! [치명적 오류] Firebase 서비스 계정 키 파일({FIREBASE_SERVICE_ACCOUNT_KEY})을 찾을 수 없습니다. Firebase 리스너 시작 불가."); return

    try:
        cred = credentials.Certificate(FIREBASE_SERVICE_ACCOUNT_KEY)
        if not firebase_admin._apps:
             firebase_app = firebase_admin.initialize_app(cred, {'databaseURL': FIREBASE_DB_URL})
             print("[성공] Firebase Admin SDK 초기화 완료.")
        else:
             firebase_app = firebase_admin.get_app()
             print("[정보] Firebase Admin SDK 이미 초기화됨.")

        print(f"Firebase 경로 '{FIREBASE_QUESTIONS_PATH}' 리스닝 시작...")
        listener_thread = threading.Thread(
            target=db.reference(FIREBASE_QUESTIONS_PATH).listen,
            args=(firebase_listener_callback,),
            daemon=True
        )
        listener_thread.start()
        print("[정보] Firebase 리스너 스레드 시작됨.")

    except Exception as e:
        print(f"!! [오류] Firebase 초기화 또는 리스너 시작 실패: {e}")
        traceback.print_exc()

# === 기본 루트 엔드포인트 ===
@app.get("/")
async def read_root():
    return {"message": "Nomu RAG Backend is running!", "initialized": is_initialized}

# === 로컬 실행용 코드 ===
if __name__ == "__main__":
    print("--- 로컬 서버 시작 (uvicorn) ---")
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)