from fastapi import FastAPI, Query
from pydantic import BaseModel
from dotenv import load_dotenv
import os
from classifier import router, set_openai_api_key, classify_text_with_openai
from routers import reservation_router

# 환경변수 불러오기
load_dotenv()
api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    raise ValueError("❌ OPENAI_API_KEY가 .env에 없습니다.")

# 모델 초기화
set_openai_api_key(api_key)

# FastAPI 앱
app = FastAPI()
app.include_router(router) # 검색 분류
app.include_router(reservation_router.router) # 예약 메일 발송

# 사용자 입력 모델
class UserInput(BaseModel):
    text: str

# 카테고리 추천 API
@app.get("/suggest")
def suggest_endpoint(query: str):
    """사용자 입력에 따른 카테고리와 자동완성 키워드 추천 API"""
    print(f"Received query: {query}")

    # 키워드를 기반으로 카테고리 찾기 (classifier.py에서 처리)
    category_result = classify_text_with_openai(query)  # 수정된 부분
    print(f"Classified category: {category_result}")

    # 자동완성 추천 (classifier.py에서 제공하는 키워드 맵 사용)
    from classifier import autocomplete_map  # 이 부분을 import하여 사용
    suggestions = autocomplete_map.get(category_result, [])
    print(f"Suggestions for category '{category_result}': {suggestions}")

    return {"category": category_result, "suggestions": suggestions}

# specialty에 맞는 노무사 필터링 함수
def filter_lawyers_by_specialty(specialty: str):
    return [lawyer for lawyer in lawyers if lawyer["specialty"] == specialty]

# ✅ 추가 (루트 엔드포인트)
@app.get("/")
async def root():
    return {"message": "Nomu Search Backend is running!"}