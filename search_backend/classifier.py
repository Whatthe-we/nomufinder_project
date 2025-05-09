import os
import random
from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
from typing import List
from openai import OpenAI
from datetime import datetime
import time

# 라우터 초기화
router = APIRouter()

# 전역 키 설정
client: OpenAI = None

def set_openai_api_key(api_key: str):
    global client
    client = OpenAI(api_key=api_key)

# 사용자 입력 모델
class UserInput(BaseModel):
    text: str

# 자동완성 키워드 맵
autocomplete_map = {
    "부당해고": ["해고", "권고사직", "기간제 계약 종료", "수습해고", "출근정지", "채용취소", "불법해고", "무단결근", "해고통보", "부당해고구제신청"],
    "부당징계": ["징계", "정직", "감봉", "해고", "경고", "징계위원회", "징계사유 미통보", "징계절차 하자", "이중징계", "대기발령"],
    "근로계약": ["근로계약서 미작성", "계약기간", "근로계약 조건 불이행", "서면 계약 미작성", "기간제 계약 종료", "근로계약 해지", "무기계약직 전환", "불리한 계약 조건", "수습 계약서", "계약 연장 거절"],
    "근무조건": ["근로시간", "주휴수당 미지급", "휴가 미부여", "근로시간 위반", "교대근무", "초과근무", "비정규직", "정규직", "유급휴가", "초과근무 강요"],
    "직장내성희롱": ["성희롱", "성추행", "성적언급", "성희롱 신고 절차", "성희롱 피해 입증", "성희롱 피해자 불이익", "성희롱 예방교육", "성희롱 퇴사", "불법촬영", "성희롱 2차 가해"],
    "직장내괴롭힘": ["괴롭힘", "폭력", "언어폭력", "모욕", "따돌림", "업무 배제", "감정노동", "사적인 업무 강요", "스트레스", "괴롭힘 퇴사"],
    "직장내차별": ["차별", "성차별", "나이 차별", "임신 후 불이익", "직급차별", "직무차별", "종교차별", "비정규직 차별", "장애인 차별", "업무 배정 차별"],
    "임금/퇴직금": ["임금체불", "급여 미지급", "지연 지급", "최저임금 위반", "급여 삭감", "연장근로 수당 미지급", "퇴직금 미지급", "임금체불 진정", "지각 공제", "퇴직금 계산"],
    "산업재해": ["산재", "근로자 재해", "산업재해 보상", "재해 보상", "직업병", "산재보험", "산재처리", "출퇴근 사고", "재해 예방법", "산재 병가"],
    "노동조합": ["노동조합", "파업", "임금협상", "노조 활동 불이익", "노동권", "노동자 권리", "노동조합 설립", "노조 파업", "노조 대표", "조합원"],
    "기업자문": ["경영자문", "법률자문", "인사관리", "급여 시스템 구축", "소규모 사업장 자문", "인사 규정 정비", "노무 감사 대응", "기업 운영 자문", "노사 협상 전략", "M&A 자문"],
    "컨설팅": ["경영 컨설팅", "IT 컨설팅", "인사 컨설팅", "조직 컨설팅", "ESG", "평가제도 도입", "인재 채용 전략", "직무분석 컨설팅", "성과관리 도입", "조직 개편 자문"],
    "급여아웃소싱": ["급여 관리", "급여 대행", "급여 계산", "세금 신고", "사회보험", "급여 지급", "급여 시스템", "급여 아웃소싱 계약", "4대보험 및 원천징수", "급여 처리"]
}
# 카테고리 목록
categories = list(autocomplete_map.keys())

# Few-shot 예시
business_examples = [
    '"무단결근한 직원의 해고가 가능한지 궁금해요" -> 부당해고',
    '"신규 사업 개시로 인해 인력 구조조정이 필요해요" -> 부당해고',
    '"지각이 잦은 직원에게 징계 가능한가요?" -> 부당징계',
    '"급여 이체가 지연되었는데 어떻게 대응해야 할까요?" -> 임금/퇴직금',
    '"성희롱 신고가 접수됐을 때 기업의 책임은?" -> 직장내성희롱',
    '"직원이 괴롭힘을 당했다고 주장해요" -> 직장내괴롭힘',
    '"산재 발생 후 회사 책임 범위를 알고 싶어요" -> 산업재해',
    '"노조가 단체행동을 예고했어요. 대응법이 있나요?" -> 노동조합',
    '"직원 평가 기준을 새로 만들고 싶어요" -> 기업자문',
    '"근로자 만족도 조사 설계가 필요합니다" -> 컨설팅',
    '"급여 시스템을 외부에 맡기려 합니다" -> 급여아웃소싱'
    '"취업규칙 개정할 때 필요한 절차가 궁금합니다" -> 기업자문',
    '"근로감독 대비 체크리스트가 필요해요" -> 기업자문',
    '"직무분석 컨설팅 어떻게 진행되나요?" -> 컨설팅',
    '"조직문화 진단을 외부에 맡기고 싶어요" -> 컨설팅',
    '"출휴 육휴 복귀자 부서 변경해도 문제 없죠?" -> 직장내차별',
    '"비정규직도 정규직처럼 연차를 줘야 하는지 궁금해요" -> 직장내차별',
]

worker_examples = [
    '"정당한 이유 없이 해고 통보를 받았어요" -> 부당해고',
    '"출근 태도 문제로 갑자기 징계를 받았어요" -> 부당징계',
    '"근로계약서를 아직도 안 줬어요" -> 근로계약',
    '"주말에 계속 근무하고 있는데 수당이 없어요" -> 근무조건',
    '"상사가 외모에 대해 말해요" -> 직장내성희롱',
    '"혼자 일하게 만들어요" -> 직장내괴롭힘',
    '"나이 때문에 승진에서 제외됐어요" -> 직장내차별',
    '"월급이 계속 지연되고 있어요" -> 임금/퇴직금',
    '"출퇴근 중 사고인데 처리가 안 됩니다" -> 산업재해',
    '"노조에 가입했더니 불이익을 받았어요" -> 노동조합'
]

casual_examples = [
    '"월급 안줌" -> 임금/퇴직금',
    '"상사 개짜증. 욕함. 어떻게 신고?" -> 직장내괴롭힘',
    '"계약서도 안주고 일만 시켜요" -> 근로계약',
    '"수습 끝나자마자 해고ㅋㅋ" -> 부당해고',
    '"야근수당 없음... 이것도 괜찮은 건가요?" -> 근무조건',
    '"성희롱 신고했더니 일 더 시켜요" -> 직장내성희롱',
    '"다쳐도 산재처리 안 해줌" -> 산업재해',
    '"노조가입했더니 부서이동ㅠㅠ" -> 노동조합',
    '"계약직인데 계약서 안 씀" -> 근로계약',
    '"매일 회식서 성적 농담해요;;" -> 직장내성희롱'
    '"육아휴직 신청하니 승진하니 싫냐고 그러네요" -> 직장내차별',
    '"기간제는 연차 원래 안주나요?" -> 직장내차별'
]

fewshot_base = business_examples + worker_examples + casual_examples

# -------------------- 1. 카테고리 분류 --------------------
def generate_prompt(user_input: str, examples: list[str], categories: list[str]) -> str:
    return f"""당신은 한국의 노동문제를 분류하는 AI 어시스턴트입니다. 아래 문장을 가장 적절한 카테고리로 분류하세요.

분류 기준
- 사용자가 권리 침해를 호소하는 경우 → 근로자 카테고리 (예: 근무조건, 부당해고, 직장내괴롭힘 등)
- 사용자가 규정 개선·리스크 점검·제도 도입을 문의하는 경우 → 사업주 카테고리 (예: 기업자문, 컨설팅 등)

아래 표현이 포함된 문장은 해당 카테고리로 분류할 가능성이 높습니다.
- 직장내차별 → “육아휴직(육휴)”, “출산휴가(출휴)”, “정년”, “비정규직”, “장애인”, “나이”, “연령” + “불이익”, “자리 변경”
- 기업자문 → “취업규칙”, “근로감독”, “사내 규정”, “교육자료”, “사건”
- 컨설팅 → “인사평가”, “성과관리”, “조직진단”, “조직문화”, “ESG”, “직무분석”, “임금피크제”, “컨설팅”
- 부당징계 → “정직”, “감봉”, “경고”, “대기발령”, “징계위원회”, “소명”, “이중징계”
- 부당해고 → “해고 통보”, “계약만료 통보”, “수습 해고”, “권고사직”, “자르다”, “내보내다”
- 직장내괴롭힘 → “모욕”, “업무 배제”, “사적 업무 지시”, “욕설”, “폭력”, “따돌림”
- 직장내성희롱 → “성희롱”, “성추행”, “성적 발언”, “2차 가해”, “불쾌한 신체 접촉”, “회식 자리에서 성적 농담”, “외모 평가”, “성희롱 신고 후 불이익”
- 노동조합 → “복수노조”, “조합원”, “단체행동”, “교섭 요구”, “노조 탈퇴 압박”, “노조활동 불이익”, “노조 설립”, “노조비 공제”, “노사 협상”, “단협(단체협약)”
- 산업재해 → “재해”, “업무상 사고”, “작업 중 사고”, “산재 신청”, “산재보험”, “병원비 처리”, “업무 중 부상”, “근골격계 질환”, “직업병”, “산재 불승- 인”, “출퇴근 교통사고”, “산재 인정 여부”
- 급여아웃소싱 → “급여명세서”, “급여 처리”, “4대보험 신고”, “원천징수”, “연말정산”, “ERP 연동”, "급여 대행", "급여 위탁"

아래 문장은 실제 근로자 또는 사업주의 질문입니다.
다음 카테고리 중 가장 적절한 하나만 선택하세요:

- {chr(10).join(f"- {cat}" for cat in categories)}

규칙:
- 반드시 위 카테고리 중 하나만 출력하세요.
- 다른 말은 출력하지 마세요.
- 문장이 모호하더라도 가장 유사한 카테고리를 선택하세요.

예시:
{chr(10).join(examples)}

사용자 문장:
"{user_input}"

👉 카테고리:"""

# 출력 정제 로직
def clean_category_output(result: str) -> str:
    for cat in categories:
        if cat in result:
            return cat
    return "분류 실패"

# 분류 함수
def classify_text_with_openai(user_input: str) -> str:
    start = time.time()

    # 중요한 오답 포인트는 항상 포함
    core_examples = [
        '"이유도 모르고 정직 당함 ;;" -> 부당징계',
        '"출휴 복귀자 자리 바꿔도 문제 없죠?" -> 직장내차별',
        '"육아휴직 후 다른 부서로 배치해도 되나요?" -> 직장내차별',
        '"정년퇴직자 재고용 의무가 있나요?" -> 직장내차별',
    ]

    # 추가로 랜덤 샘플
    examples = (
        core_examples +
        random.sample(business_examples, 2) +
        random.sample(worker_examples, 2) +
        random.sample(casual_examples, 2)
    )

    prompt = generate_prompt(user_input, examples, categories)

    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=50,
        )
        raw_result = response.choices[0].message.content.strip()
        print(f"🔍 Raw Output: {raw_result}")
        print(f"⏱️ GPT 응답 시간: {time.time() - start:.2f}초")

        cleaned = clean_category_output(raw_result)

        return cleaned
    except Exception as e:
        print("❌ OpenAI API 오류:", e)
        return "분류 실패"

# -------------------- 2. 자동완성 키워드 추천 --------------------
# 추천 키워드 3개 뽑기 위한 프롬프트
def get_ranked_keywords_prompt(user_input: str, category: str, keywords: List[str]) -> str:
    return f"""당신은 노동 문제 분류 및 키워드 추천 AI입니다.

아래는 사용자의 문장과 분류된 카테고리, 해당 카테고리에 속하는 고정 키워드 목록입니다.
사용자의 문장과 가장 관련 있는 키워드를 **반드시 고정 키워드 목록 안에서만** 추천해 주세요.
목록에 없는 단어를 새로 생성하거나 추가하지 마세요.

이 문장과 **가장 관련 높은 3개의 키워드를 순위대로 출력**해주세요.
형식: ["키워드1", "키워드2", "키워드3"]

---
문장: "{user_input}"
카테고리: {category}
가능한 키워드 목록: {', '.join(keywords)}
---
"""

# GPT에게 추천 요청
def get_top3_keywords_with_gpt(user_input: str, category: str, keywords: List[str]) -> List[str]:
    try:
        prompt = get_ranked_keywords_prompt(user_input, category, keywords)
        response = client.chat.completions.create(
            model="gpt-4",  # 또는 "gpt-3.5-turbo"로도 가능
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
        )
        output = response.choices[0].message.content
        print("🎯 GPT 키워드 추천:", output)
        start = output.index("[")
        end = output.index("]", start)
        return eval(output[start:end+1])  # 문자열 → 리스트 변환
    except Exception as e:
        print("❌ 키워드 추천 실패:", e)
        return keywords[:3]  # 실패 시 앞 3개 반환

# 전체 키워드 중 우선순위 3개 + 나머지를 정렬하여 반환
def get_llm_sorted_suggestions(user_input: str, category: str) -> List[str]:
    keywords = autocomplete_map.get(category, [])
    top3 = get_top3_keywords_with_gpt(user_input, category, keywords)
    remaining = [kw for kw in keywords if kw not in top3]
    return top3 + remaining

# ------------------- FastAPI 엔드포인트 --------------------
@router.post("/classify")
async def classify_endpoint(user_input: UserInput):
    result = classify_text_with_openai(user_input.text)

    # 자동완성 키워드 매칭
    suggestions = get_llm_sorted_suggestions(user_input.text, result)

    return {
        "category": result,
        "suggestions": suggestions
    }