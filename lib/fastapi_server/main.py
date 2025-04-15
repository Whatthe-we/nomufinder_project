from fastapi import FastAPI, Query
from pydantic import BaseModel
from typing import List
from classifier import classify_text_with_gemini  # ✅ 함수 임포트
from classifier import router  # ✅ 라우터 import

app = FastAPI()
app.include_router(router)     # ✅ 라우터 등록

# 사용자 입력을 위한 데이터 모델
class UserInput(BaseModel):
    text: str

# Gemini 분류 API
@app.post("/classify")
async def classify_endpoint(user_input: UserInput):
    result = classify_text_with_gemini(user_input.text)
    return {"category": result}

# 추천 문장 API (GET)
@app.get("/suggest")
def suggest_endpoint(user_type: str = Query("worker")):
    if user_type == "employer":
        return {"suggestions": [
            "직원 인사평가 시스템 개선이 필요해요",
            "복지제도에 대해 외부 컨설팅이 필요해요",
            "급여를 외부에 맡기고 싶어요",
            "노조와의 협상 방안을 고민하고 있어요",
            "작업장 안전 점검을 받고 싶습니다"
        ]}
    else:
        return {"suggestions": [
            "퇴직금을 아직 못 받았어요",
            "계약서를 안 써줬습니다",
            "야근 수당이 없어요",
            "출산 후 부서가 바뀌었어요",
            "작업 중 다쳤는데 산재 처리를 안 해줘요"
        ]}