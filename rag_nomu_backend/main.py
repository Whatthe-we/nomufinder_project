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

# === 🔄 후속질문 분류기 및 생성기 함수 (main.py 내부에 통합) ===
from typing import List, Tuple
from langchain_openai import ChatOpenAI
import os

# === 분류기: 질문이 아닌 일반 진술인지 확인 ===
def classify_need_for_question(user_input: str) -> bool:
    """
    유저 입력이 질문이 아니라 단순 진술(예: "나는 사업을 하고 있어요")일 경우 True 반환
    """
    question_keywords = ["뭐야", "뭔가요", "어떻게", "무엇", "언제", "왜", "얼마", "가능해", "되나요", "인가요", "?"]
    if user_input.endswith("?"):
        return False
    if any(kw in user_input for kw in question_keywords):
        return False
    return True

# === 생성기: 후속 질문 생성 (맥락 기반) ===
def generate_followup_question(user_input: str, chat_history: List[Tuple[str, str]]) -> str:
    """
    유저의 진술을 기반으로, 어떤 추가 질문을 하면 좋을지 LLM으로 생성
    (이전 대화 기록을 함께 고려함)
    """
    openai_key = os.getenv("OPENAI_API_KEY")
    if not openai_key:
        raise ValueError("OPENAI_API_KEY 환경변수가 설정되지 않았습니다.")

    llm = ChatOpenAI(model_name="gpt-4.1", temperature=0, openai_api_key=openai_key)

    history_prompt = ""
    for user_msg, ai_msg in chat_history[-3:]:  # 최근 3턴만 사용
        history_prompt += f"사용자: {user_msg}\n챗봇: {ai_msg}\n"

    prompt = f"""
너는 한국 노동법 기반 챗봇이야.
아래는 사용자와의 최근 대화 기록과 현재 발화입니다.

{history_prompt}

현재 발화: \"{user_input}\"

이 발화는 질문이 아니라 진술일 가능성이 있습니다.
법적 상담에 필요한 핵심 정보를 얻기 위해 이어서 해야 할 가장 적절한 후속 질문 하나를 자연스럽게 생성하세요.

단, 너무 포괄적인 질문(예: \"무슨 도움이 필요하세요?\")은 피하고, 구체적이고 실용적인 질문을 생성하세요.
후속 질문:
"""

    try:
        response = llm.invoke(prompt)
        return response.content.strip()
    except Exception as e:
        print(f"!! 후속 질문 생성 실패: {e}")
        return ""

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
LLM_MODEL_NAME = "gpt-4.1"                      # ✅  사용할 LLM 모델
# =====================

# Firebase 설정 (환경 변수에서 로드)
FIREBASE_DB_URL = os.getenv("FIREBASE_DATABASE_URL")
if not FIREBASE_DB_URL:
    print("!! [치명적 오류] .env 파일에서 FIREBASE_DATABASE_URL을 찾을 수 없습니다. 앱 실행 불가.")
FIREBASE_QUESTIONS_PATH = "/chat_questions"
FIREBASE_ANSWERS_PATH = "/chat_answers"
QUESTION_LOG_PATH = "chat_log.json"

# Retriever 설정값                               # ✅ 업데이트
FAISS_K = 4
BM25_K = 4
ENSEMBLE_WEIGHTS = [0.4, 0.6] # BM25=0.4, FAISS=0.6

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
        llm = ChatOpenAI(model_name=LLM_MODEL_NAME, temperature=0, openai_api_key=openai_api_key)
        print("LLM 로드 완료.")

        # 5. RAG Chain 구축 (기존과 동일) # ✅ 프롬프트 개선
        print("RAG Chain 구축 중...")
        template = """당신은 한국의 노무 규정 및 관련 문서에 기반하여 질문에 답변하는 유용한 AI 어시스턴트입니다. 이름(명칭)은 노무무입니다.

        [답변 방식]
        - 질문자의 상황에 공감하는 짧은 인삿말 또는 격려 문장으로 시작해 주세요. (예: "육아와 일을 병행하시느라 많이 바쁘시죠?")
        - 핵심 정보를 가장 먼저, 간결한 문장으로 제시해 주세요.
        - 필요한 경우 예시나 조건을 덧붙여 주세요.
        - 답변의 끝맺음은 "~입니다."보다는 "~이에요.", "~할 수 있어요.", "~하셔야 해요."처럼 **부드러운 종결어미 (~요)** 로 통일해 주세요.
        - 법령의 의미는 일반 사용자가 이해할 수 있도록 쉽게 풀어 설명해 주세요.
        - 문서에 없는 수치 표현(예: 5인 미만)이라도 의미가 동일한 경우(예: 4명 이하)로 논리적으로 해석하여 설명해 주세요.
        - 질문에 대한 명확한 조항이 문서에 없더라도, 질문이 일반적이고 상식적이라면 LLM의 일반 지식을 바탕으로 신중히 보완해 주세요.
        - 너무 긴 문단 없이, **가독성을 높이기 위해 2~3문장 단위로 줄을 바꿔** 주세요.
        - 관련 조항이 있는 경우에는 판단을 미루지 말고, 해당 조문을 바탕으로 명확히 답변해 주세요.
        - 형사처벌·벌금·과태료 조항이 문서에 명시되어 있다면 반드시 포함해 주세요.

        [신뢰성 및 최신 법령 반영 조건]
        - 2025년 기준 최신 개정 법령을 기반으로 답변해 주세요. (예: 육아휴직 1년 6개월)
        - 위반 시 제재 수위는 "행정처분", "과태료", "형사처벌" 중 구체적으로 구분해 주세요.
        - 해당 제재 조항이 문서에 없거나 명확하지 않은 경우에는 "문서만으로는 판단이 어려워요."라고 안내해 주세요.
        - 법령에 명시된 경우에만 형사처벌이나 과태료 내용을 언급해 주세요.
        - 해석이 분분하거나 쟁점이 있는 경우에도 "문서만으로는 판단이 어려워요."라고 안내해 주세요.
        - 단정적이거나 기계적인 표현은 피하고, 부드럽고 책임감 있는 말투로 마무리해 주세요.
        - 일반적인 법률 지식을 활용하되, 문서의 내용을 우선하여 신중하게 작성해 주세요.
        - 질문이 일반적이고 컨텍스트에 관련 조항이 없을 경우, LLM의 일반적인 법률 지식을 기반으로 보완하되, 문서보다 우선하지 않도록 주의하십시오.
        - 특히 노동 관련 법령에서 제재 수위는 핵심이므로 누락 없이 서술하십시오.

        [언어 스타일]
        - 기계적인 표현은 피하고, 자연스러운 설명형 문장으로 작성해 주세요.
        - 문장 끝은 "~입니다."보다는 "~이에요", "~하셔야 해요", "~하실 수 있어요" 등의 부드러운 말투를 사용해 주세요.
        - 예시 표현은 매번 "예를 들어"보다는 "예컨대", "보통 이런 경우", "예시를 들면" 등으로 자연스럽게 다양화해 주세요.
        - 핵심 정보 → 예시 → 조건/예외 → 마무리 안내 순으로 작성해 주세요.
        - 너무 긴 문단 없이 자연스럽게 문단을 나누어 주세요.
        - 필요한 경우 "더 자세한 내용은 노무사 상담이나 회사 내규 확인이 필요해요."와 같이 안내해 주세요.
        - 마크다운 굵은 글자 등 특수 포맷은 사용하지 말고, 일반 텍스트로 출력해 주세요.

        [정리]
        - 질문자가 불안하거나 혼란스러울 수 있는 상황일 경우, 짧고 자연스러운 **공감 표현**으로 답변을 시작해 주세요. (예: “이런 상황에서는 혼란스러우실 수 있어요.”)
        - 단순한 사실 확인 질문일 경우에는 공감 표현 없이 바로 **핵심 정보**부터 제시해 주세요.
        - 전체 답변은 다음 순서로 구성하세요:
          1. (조건부) 공감 표현 1문장
          2. 핵심 정보 요약
          3. 예시 또는 일반적인 적용 조건
          4. 제한사항 또는 유의사항
        - 너무 형식적이지 않게, 대화하듯 편안하고 믿을 수 있는 말투로 설명해 주세요."

            컨텍스트:
            {context}

            질문: {question}

            답변 (한국어):"""

        QA_CHAIN_PROMPT = PromptTemplate(
            input_variables=["context", "question"],
            template=template
        )

        if not retriever: raise ValueError("Retriever 객체가 성공적으로 생성되지 않았습니다.")
        if not llm: raise ValueError("LLM 객체가 성공적으로 생성되지 않았습니다.")

        global qa_chain # 전역 변수 할당 명시
        qa_chain = RetrievalQA.from_chain_type(
            llm=llm,
            chain_type="stuff",
            retriever=retriever,
            return_source_documents=True,
            chain_type_kwargs={
                    "prompt": QA_CHAIN_PROMPT
                },
                input_key="question"  # ✅ 추가
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

        # ✅ 최근 5개 ID만 추출 (timestamp 기준)
        sorted_items = sorted(
            event.data.items(),
            key=lambda item: item[1].get("timestamp", 0),
            reverse=True
        )
        recent_items = sorted_items[:5]  # 가장 최신 5개만

        for question_id, question_data in recent_items:
            if isinstance(question_data, dict) and ("query" in question_data or "chat_history" in question_data):
                handle_single_question(question_id, question_data)
        return

    # 단일 질문 감지
    if event.event_type == 'put' and event.data:
        if isinstance(event.data, dict) and ("query" in event.data or "chat_history" in event.data):
            question_id = event.path.strip("/").split("/")[-1]
            handle_single_question(question_id, event.data)
            return

    print(f"⚠️ 무시된 이벤트 또는 query/chat_history 없음: {event.path}, 데이터: {event.data}")

def handle_single_question(question_id, question_data):
    global qa_chain, processed_question_ids

    question_time = question_data.get("timestamp", 0)
    if question_id in processed_question_ids:
        print(f"⚠️ 이미 처리된 질문: {question_id} → 스킵함")
        return

    # 기본 query 또는 chat_history
    query = question_data.get("query", "").strip()
    chat_history = question_data.get("chat_history", [])

    if not query and not chat_history:
        print(f"⚠️ 질문 내용이 비어있음: {question_id}")
        return

    try:
        print(f"  ✅ 유효한 질문 감지됨 (ID: {question_id})")
        print("  RAG 답변 생성 시도...")
        start_time = time.time()

        followup = None

        # 🔄 chat_history 문맥 기반 답변
        if isinstance(chat_history, list) and chat_history:
            print("  🔍 chat_history 기반 문맥 처리 중...")
            context_string = "\n".join(
                f"{item['role'].capitalize()}: {item['content']}"
                for item in chat_history if 'role' in item and 'content' in item
            )
            final_question = chat_history[-1]['content']  # 마지막 사용자 발화만 추출

            # 후속질문 필요 여부 판단
            need_followup = classify_need_for_question(final_question)
            chat_history_tuples = [(msg['content'], "") for msg in chat_history if msg['role'] == 'user']
            followup = generate_followup_question(final_question, chat_history_tuples) if need_followup else ""

            full_question = f"""
다음은 사용자와의 최근 대화입니다.
{context_string}

[질문]
{final_question}
""".strip()

        else:
            # chat_history가 없을 때는 query를 바로 질문으로 사용
            final_question = query or "질문이 없습니다."
            full_question = final_question

            # ✅ chat_history가 없을 때도 후속질문 판단 및 생성 추가
            if query:
                need_followup = classify_need_for_question(query)
                if need_followup:
                    followup = generate_followup_question(query, [(query, "")])

        # ✅ 실제 GPT 호출
        result = qa_chain.invoke({
            "context": "",
            "question": full_question,
        })

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
            "followup_question": followup or "",  # ✅ 후속 질문 함께 저장
        })
        print(f"  Firebase '{FIREBASE_ANSWERS_PATH}/{question_id}' 경로에 답변 저장 완료.")

        # ✅ 기록 및 로그 저장
        save_processed_id(question_id)
        log_question_answer_pair(question_id, query or final_question, answer)

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