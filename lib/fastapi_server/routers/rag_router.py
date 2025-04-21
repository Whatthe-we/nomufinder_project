from fastapi import APIRouter
from fastapi_server.models.rag_model import RAGRequest, RAGResponse
from fastapi_server.rag.rag_initializer import run_rag

router = APIRouter()

@router.post("/rag", response_model=RAGResponse)
def get_rag_response(request: RAGRequest):
    result = run_rag(request.query)
    return RAGResponse(response=result)