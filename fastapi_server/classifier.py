import os
import random
from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
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

# Few-shot 예시 (공식 +
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
]

fewshot_base = business_examples + worker_examples + casual_examples

# 생성 함수
def generate_prompt(user_input: str, examples: list[str], categories: list[str]) -> str:
    return f"""당신은 한국의 노동문제를 분류하는 AI 어시스턴트입니다.
아래 문장은 실제 근로자/사업주가 질문한 내용이며,
이 문장을 가장 잘 설명하는 카테고리를 다음 중 하나로 선택하세요:

- {chr(10).join(f"- {cat}" for cat in categories)}

규칙:
- 반드시 위 카테고리 중 하나만 출력하세요.
- 다른 말은 출력하지 마세요.
- 분류가 어려워도 가장 유사한 카테고리를 선택하세요.

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

# 오분류 로그 저장
def log_failed_classification(user_input: str, result: str):
    now = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_dir = "classified_logs"
    os.makedirs(log_dir, exist_ok=True)
    with open(os.path.join(log_dir, f"fail_{now}.txt"), "w", encoding="utf-8") as f:
        f.write(f"문장: {user_input}\n")
        f.write(f"예측 결과: {result}\n")

# 분류 함수
def classify_text_with_openai(user_input: str) -> str:
    start = time.time()

    # ✅ 예시 6개만 사용 (카테고리 다양성 확보)
    examples = (
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

        # Feedback Loop용 오분류 로그 저장
        if cleaned == "분류 실패":
            log_failed_classification(user_input, raw_result)

        return cleaned
    except Exception as e:
        print("❌ OpenAI API 오류:", e)
        return "분류 실패"

# FastAPI 엔드포인트
@router.post("/classify")
async def classify_endpoint(user_input: UserInput):
    result = classify_text_with_openai(user_input.text)
    return {"category": result}