import time, traceback
from firebase_admin import db
from fastapi_server.rag.rag_initializer import qa_chain

def firebase_listener_callback(event):
    path = event.path
    data = event.data

    if event.event_type != "put" or not data:
        return

    try:
        question_id = path.split("/")[-1]
        query = data.get("query", "")
        if not query: return

        print(f"[Firebase] 질문 수신됨: {query}")

        result = qa_chain.invoke({"query": query})
        answer = result.get("result", "답변 생성 실패")
        sources = result.get("source_documents", [])

        db.reference(f"/chat_answers/{question_id}").set({
            "answer": answer,
            "sources": [{"content": doc.page_content[:100]} for doc in sources[:2]],
            "timestamp": int(time.time())
        })

    except Exception as e:
        print(f"[오류] Firebase RAG 응답 실패: {e}")
        traceback.print_exc()