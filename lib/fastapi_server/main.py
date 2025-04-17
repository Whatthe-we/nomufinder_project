from fastapi import FastAPI, Query
from pydantic import BaseModel
import os
import google.generativeai as genai
from dotenv import load_dotenv
from classifier import router, set_model, classify_text_with_gemini  # classify_text_with_gemini를 import

# Gemini 모델 초기화
load_dotenv()
api_key = os.getenv("GOOGLE_API_KEY", "여기에_API_키_입력")  # 실제 API 키 사용
genai.configure(api_key=api_key)
model_name = "models/gemini-1.5-pro-latest"
model = genai.GenerativeModel(model_name=model_name)
set_model(model)

# FastAPI 앱 생성 및 라우터 등록
app = FastAPI()
app.include_router(router)

# 사용자 입력 모델
class UserInput(BaseModel):
    text: str

# 카테고리 추천 API
@app.get("/suggest")
def suggest_endpoint(query: str):
    """사용자 입력에 따른 카테고리와 자동완성 키워드 추천 API"""
    print(f"Received query: {query}")

    # 키워드를 기반으로 카테고리 찾기 (classifier.py에서 처리)
    category_result = classify_text_with_gemini(query)  # 수정된 부분
    print(f"Classified category: {category_result}")

    # 자동완성 추천 (classifier.py에서 제공하는 키워드 맵 사용)
    from classifier import autocomplete_map  # 이 부분을 import하여 사용
    suggestions = autocomplete_map.get(category_result, [])
    print(f"Suggestions for category '{category_result}': {suggestions}")

    return {"category": category_result, "suggestions": suggestions}
