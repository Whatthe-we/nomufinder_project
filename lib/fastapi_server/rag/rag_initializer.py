from langchain.chains import RetrievalQA
from langchain.prompts import PromptTemplate
from langchain.retrievers import EnsembleRetriever
from langchain_community.vectorstores import FAISS
from langchain_community.retrievers import BM25Retriever
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
import os, pickle
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent  # fastapi_server/
INDEX_DIR = BASE_DIR / "faiss_index_nomu_final"

qa_chain = None  # 전역 체인 객체

def initialize_rag():
    global qa_chain

    openai_api_key = os.getenv("OPENAI_API_KEY")
    embedding_model = OpenAIEmbeddings(model="text-embedding-ada-002", openai_api_key=openai_api_key)
    llm = ChatOpenAI(model_name="gpt-4", openai_api_key=openai_api_key, temperature=0)

    # ✅ 절대경로 기반 FAISS 인덱스 로딩
    vectorstore = FAISS.load_local(
        str(INDEX_DIR),
        embedding_model,
        allow_dangerous_deserialization=True
    )
    retriever_dense = vectorstore.as_retriever(search_kwargs={"k": 6})

    # ✅ BM25 문서도 절대 경로로 로딩
    with open(BASE_DIR / "split_texts_for_bm25.pkl", "rb") as f:
        docs = pickle.load(f)
    retriever_sparse = BM25Retriever.from_documents(docs)
    retriever_sparse.k = 6

    ensemble_retriever = EnsembleRetriever(
        retrievers=[retriever_sparse, retriever_dense],
        weights=[0.7, 0.3]
    )

    prompt_template = PromptTemplate.from_template("""
    아래 컨텍스트를 바탕으로 사용자 질문에 정확히 답해주세요.
    문서에 정보가 없으면 '답변할 수 없습니다'라고 답하세요.
    컨텍스트: {context}
    질문: {question}
    답변:
    """)

    qa_chain = RetrievalQA.from_chain_type(
        llm=llm,
        chain_type="stuff",
        retriever=ensemble_retriever,
        return_source_documents=True,
        chain_type_kwargs={"prompt": prompt_template}
    )

def run_rag(query: str) -> str:
    if not qa_chain:
        return "❌ RAG 체인이 초기화되지 않았습니다."

    result = qa_chain.invoke({"query": query})
    return result.get("result", "❌ 답변 생성 실패")