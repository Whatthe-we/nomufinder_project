from pydantic import BaseModel

class RAGRequest(BaseModel):
    query: str

class RAGResponse(BaseModel):
    response: str