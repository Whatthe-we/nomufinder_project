from fastapi import FastAPI, Query
from pydantic import BaseModel
from typing import List, Optional
import os
import google.generativeai as genai
from dotenv import load_dotenv
# 모듈 임포트 - classifier.py에서 라우터와 함수 가져오기
from classifier import router, set_model, classify_text_with_gemini

# 먼저 기본 .env 파일 로드 시도
load_dotenv()

# 환경에 따른 추가 .env 파일 로드
is_emulator = os.getenv('IS_EMULATOR', 'false').lower() == 'true'
if is_emulator:
    load_dotenv(dotenv_path='.env.dev', override=True)  # 애뮬레이터 환경
else:
    load_dotenv(dotenv_path='.env.prod', override=True)  # 웹 환경 (프로덕션)

# 환경 변수 로드 확인
api_key = os.getenv("GOOGLE_API_KEY")
if not api_key:
    print("⚠️ .env 파일에서 GOOGLE_API_KEY를 찾을 수 없습니다.")
    # 개발 중이라면 임시로 직접 설정할 수 있습니다 (배포 시에는 제거)
    api_key = "여기에_API_키_입력"  # 테스트 후 제거하세요!

if not api_key:
    raise Exception("❌ GOOGLE_API_KEY 환경변수가 없습니다.")

# Gemini 모델 설정
genai.configure(api_key=api_key)
model_name = "models/gemini-1.5-pro-latest"
model = genai.GenerativeModel(model_name=model_name)

# classifier.py에 모델 전달
set_model(model)

# FastAPI 앱 생성 및 라우터 등록
app = FastAPI()
app.include_router(router)

# 사용자 입력 모델
class UserInput(BaseModel):
    text: str

# 카테고리별 자동완성 키워드 맵 (근로자 + 사업주 통합)
autocomplete_map = {
    # 근로자 카테고리
    "부당해고": ["해고", "권고사직", "계약종료", "수습해고", "출근정지"],
    "부당징계": ["징계", "경고장", "정직", "감봉", "징계사유"],
    "근로계약": ["근로계약서", "계약조건", "계약서 미작성", "계약기간", "계약변경"],
    "근무조건": ["근무시간", "휴게시간", "초과근무", "야근수당", "무급노동"],
    "직장 내 성희롱": ["성희롱", "외모평가", "성적농담", "불쾌한 언행", "회식 성희롱"],
    "직장 내 괴롭힘": ["괴롭힘", "따돌림", "모욕", "과도한업무", "감정노동"],
    "직장 내 차별": ["차별", "남녀차별", "고용형태", "승진차별", "연령차별"],
    "임금체불": ["임금체불", "퇴직금", "연차수당", "주휴수당", "급여 미지급"],
    "산업재해": ["산재", "다쳤어요", "산재신청", "산재보험", "출퇴근 사고"],
    "노동조합": ["노조", "단체행동", "조합활동", "노조가입", "노조탄압"],

    # 사업주 카테고리
    "기업자문": ["인사관리", "근태관리", "내부규정", "규정개정", "인사시스템"],
    "컨설팅": ["외부자문", "인사컨설팅", "조직진단", "제도개선", "만족도조사"],
    "급여 아웃소싱": ["급여아웃소싱", "급여위탁", "퇴직정산", "세금신고", "외부회계"],
}

# 카테고리 추천 API
@app.get("/suggest")
def suggest_endpoint(query: str):
    """사용자 입력에 따른 카테고리와 자동완성 키워드 추천 API"""
    print(f"Received query: {query}")

    # 카테고리 분류
    category_result = classify_text_with_gemini(query)
    print(f"Classified category: {category_result}")

    # 자동 완성 추천
    suggestions = autocomplete_map.get(category_result, [])
    print(f"Suggestions for category '{category_result}': {suggestions}")

    return {"category": category_result, "suggestions": suggestions}