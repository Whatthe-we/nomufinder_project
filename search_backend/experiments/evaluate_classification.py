import json
import sys
import csv
import os
import datetime
from openai import OpenAI
from dotenv import load_dotenv
from sklearn.metrics import classification_report, accuracy_score

# classifier.py 상대경로 import 허용
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from classifier import (
    categories,
    clean_category_output,
    classify_text_with_openai
)

# === 모델 세팅 ===
load_dotenv()
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
classify_text_with_openai.__globals__["client"] = client

# === 평가 데이터 ===
def generate_eval_dataset(path="search_backend/experiments/evaluation_dataset.json"):
    dataset = [
        # 부당해고&부당징계 - 근로자
        {"text": "수습 끝나자마자 나가라는데 ㅋㅋ", "label": "부당해고"},
        {"text": "이유도 모르고 정직 당함 ;;", "label": "부당징계"},
        {"text": "정당한 사유가 없는데 계약 종료 하겠대요", "label": "부당해고"},
        {"text": "제 의견을 소명할 기회 없이 감봉 조치 받았습니다", "label": "부당징계"},
        {"text": "회사에서 경고를 계속 줘요", "label": "부당징계"},
        # 부당해고&부당징계 - 사업주
        {"text": "수습 사원 실력 너무 부족함,, 솔직히 내보내고 싶음", "label": "부당해고"},
        {"text": "직원의 불성실한 근태로 인한 징계 절차가 궁금합니다", "label": "부당징계"},
        {"text": "계약 만료되고 바로 재계약 거절하면 문제됨?", "label": "부당해고"},
        {"text": "직원한테 경고 조치를 할 때 주의할 점이 있나요?", "label": "부당징계"},
        {"text": "정직 처분 시 필요한 절차는 무엇인가요?", "label": "부당징계"},

        # 근로계약&근무조건 - 근로자
        {"text": "계약서 아직도 안씀;;", "label": "근로계약"},
        {"text": "주 60시간 넘게 일하고 있어요", "label": "근무조건"},
        {"text": "연차를 쓸 수 없게 막아요", "label": "근무조건"},
        {"text": "근로계약 내용과 실제 근로조건이 달라요", "label": "근로계약"},
        {"text": "계약서에는 주5일 근무인데 실제로는 주6일 일합니다", "label": "근로계약"},
        # 근로계약&근무조건 - 사업주
        {"text": "계약서 언제까지 써야 되는 거임?", "label": "근로계약"},
        {"text": "연장근로 시 수당 지급 기준은 뭔가요?", "label": "근무조건"},
        {"text": "수습 기간만 급여를 조정할 수 있나요?", "label": "근로계약"},
        {"text": "연차 그냥 우리가 정해도 되는 거 아님?", "label": "근무조건"},
        {"text": "근로시간 단축 요청을 거부해도 되나요?", "label": "근무조건"},

        # 직장내성희롱&괴롭힘 - 근로자
        {"text": "상사 외모 지적 계속함... 기분 진짜 별로", "label": "직장내성희롱"},
        {"text": "성희롱 신고 이후 보복을 당했어요", "label": "직장내성희롱"},
        {"text": "괴롭힘으로 인해 퇴사하고 싶은데 실업급여 받을 수 있나요?", "label": "직장내괴롭힘"},
        {"text": "욕설 박고 무시하고... 개무시당함", "label": "직장내괴롭힘"},
        {"text": "집단 따돌림을 당하고 있어요", "label": "직장내괴롭힘"},
        # 직장내성희롱&괴롭힘 - 사업주
        {"text": "성희롱 예방교육 이거 꼭 해야 됨?", "label": "직장내성희롱"},
        {"text": "직장 내 괴롭힘 신고 접수 시 조치 방법은?", "label": "직장내괴롭힘"},
        {"text": "성희롱 신고가 거짓일 경우 대응은?", "label": "직장내성희롱"},
        {"text": "직장 내 괴롭힘 가해자 징계 절차는?", "label": "직장내괴롭힘"},
        {"text": "따돌림 신고 들어왔는데 뭐부터 해야 함?", "label": "직장내괴롭힘"},

        # 직장내차별 - 근로자
        {"text": "출휴 갔다 왔더니 자리 바뀌어 있음;;", "label": "직장내차별"},
        {"text": "비정규직이라 연차 얘기 꺼내기도 눈치 보여요", "label": "직장내차별"},
        {"text": "육아휴직 복귀 후 불이익을 당했어요", "label": "직장내차별"},
        {"text": "나이 때문에 승진이 안 된 것 같아요", "label": "직장내차별"},
        {"text": "장애인이라고 워크샵 오지 말래요", "label": "직장내차별"},
        # 직장내차별 - 사업주
        {"text": "출휴 복귀자 자리 바꿔도 문제 없죠?", "label": "직장내차별"},
        {"text": "비정규직도 연차 줘야 함?", "label": "직장내차별"},
        {"text": "육아휴직 후 다른 부서로 배치해도 되나요?", "label": "직장내차별"},
        {"text": "정년퇴직자 재고용 의무가 있나요?", "label": "직장내차별"},
        {"text": "장애인 의무고용 비율 미달 시 불이익은?", "label": "직장내차별"},

        # 임금/퇴직금 - 근로자
        {"text": "퇴직금 정산이 늦어지고 있어요", "label": "임금/퇴직금"},
        {"text": "월급이 정해진 날짜에 안 들어와요", "label": "임금/퇴직금"},
        {"text": "수습인데 최저도 안 줌 ㅋㅋ 말이 됨?", "label": "임금/퇴직금"},
        {"text": "퇴사했는데 아직도 월급 안 줌;;;", "label": "임금/퇴직금"},
        {"text": "퇴직금이 적게 나왔어요", "label": "임금/퇴직금"},
        # 임금/퇴직금 - 사업주
        {"text": "퇴직금 언제까지 주면 되는 거임?", "label": "임금/퇴직금"},
        {"text": "임금 체불 시 법적 책임은 어떻게 되나요?", "label": "임금/퇴직금"},
        {"text": "퇴직금 계산 기준을 알고 싶어요", "label": "임금/퇴직금"},
        {"text": "하루만 나오고 결근했는데 돈 줘야 함??", "label": "임금/퇴직금"},
        {"text": "퇴직금 중간정산 꼭 해줘야 하는건가요?", "label": "임금/퇴직금"},

        # 산업재해 - 근로자
        {"text": "출근길 교통사고 산재 처리 가능할까요?", "label": "산업재해"},
        {"text": "일하다 허리 나갔는데 병원비도 내 돈으로 내라 함;;", "label": "산업재해"},
        {"text": "산재 신청했더니 회사에서 싫어해요", "label": "산업재해"},
        {"text": "작업 중 다쳤는데 병원비가 걱정돼요", "label": "산업재해"},
        {"text": "야근하다 다쳤는데 산재 얘기 꺼냈더니 눈치줌;", "label": "산업재해"},
        # 산업재해 - 사업주
        {"text": "산재 이거 무조건 받아줘야 함?", "label": "산업재해"},
        {"text": "업무상 재해 인정 기준이 궁금합니다", "label": "산업재해"},
        {"text": "산재 처리 시 회사 책임 범위는?", "label": "산업재해"},
        {"text": "회사 밖에서 발생한 출퇴근 중 사고도 우리 책임임?", "label": "산업재해"},
        {"text": "산재 예방 조치를 못 하면 어떤 처벌을 받나요?", "label": "산업재해"},

        # 노동조합 - 근로자
        {"text": "노조 들어간다니까 바로 눈치 줌... 뭐냐 진짜", "label": "노동조합"},
        {"text": "노조 가입했더니 이상하게 다른 부서로 빼더라", "label": "노동조합"},
        {"text": "노조 가입비는 반드시 내야 하나요?", "label": "노동조합"},
        {"text": "노조 가입을 이유로 전출 당했어요", "label": "노동조합"},
        {"text": "파업에 참가하면 징계 당할 수 있나요?", "label": "노동조합"},
        # 노동조합 - 사업주
        {"text": "파업해도 월급 줘야 함?? 진심?", "label": "노동조합"},
        {"text": "노조 애들 때문에 정리 못 하겠음... 어떻게 함?", "label": "노동조합"},
        {"text": "복수노조 대응 방법이 필요합니다", "label": "노동조합"},
        {"text": "노조 파업 시 임금 지급 의무가 있나요?", "label": "노동조합"},
        {"text": "노동조합에 협박성 요구를 받을 때 어떻게 하나요?", "label": "노동조합"},

        # 기업자문 - 사업주
        {"text": "취업규칙 바꾸려면 뭐부터 해야 함?", "label": "기업자문"},
        {"text": "노무 리스크 예방을 위한 점검 방법은?", "label": "기업자문"},
        {"text": "근로감독 대비 준비할 수 있는 게 뭔가요?", "label": "기업자문"},
        {"text": "정리해고 하려면 절차 진짜 다 밟아야 해요?", "label": "기업자문"},
        {"text": "신규 입사자 교육 자료를 사내 규정으로 준비하려 합니다", "label": "기업자문"},

        # 컨설팅 - 사업주
        {"text": "인사평가 외주 줄까 하는데 어디다 맡겨야 하나요?", "label": "컨설팅"},
        {"text": "조직문화 진단 컨설팅 받고 싶습니다", "label": "컨설팅"},
        {"text": "요즘 ESG 컨설팅 이런 거 다 해야 됨?", "label": "컨설팅"},
        {"text": "임금피크제 도입을 고민하고 있습니다", "label": "컨설팅"},
        {"text": "직무분석 컨설팅 절차가 궁금해요", "label": "컨설팅"},

        # 급여아웃소싱 - 사업주
        {"text": "급여 대행 서비스 비용은 얼마나 하나요?", "label": "급여아웃소싱"},
        {"text": "급여 대행 맡기면 퇴직금도 알아서 해줌??", "label": "급여아웃소싱"},
        {"text": "4대보험 이런 것도 같이 처리돼요?", "label": "급여아웃소싱"},
        {"text": "비정규직 급여 계산도 대행 가능한가요?", "label": "급여아웃소싱"},
        {"text": "급여자료 제공 방식은 어떻게 되나요?", "label": "급여아웃소싱"},
    ]
    with open(path, "w", encoding="utf-8") as f:
        json.dump(dataset, f, ensure_ascii=False, indent=2)
    print(f"✅ 평가셋 저장됨: {path}")
    return dataset

# === Zero-shot 분류 함수 ===
def classify_text_zeroshot(user_input: str) -> str:
    prompt = f"""
당신은 아래 문장을 분류하는 AI입니다.
문장을 아래 카테고리 중 하나로 분류하세요:

- {', '.join(categories)}

문장: {user_input}
카테고리:"""
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=50,
        )
        result = response.choices[0].message.content.strip()
        return clean_category_output(result)
    except Exception as e:
        print("❌ Zero-shot 오류:", e)
        return "분류 실패"

# === 오답 로그 저장 ===
def save_misclassified_log(name, y_true, y_pred, dataset, path_prefix="search_backend/experiments"):
    misclassified = []
    for i, (true, pred) in enumerate(zip(y_true, y_pred)):
        if true != pred:
            misclassified.append({
                "model": name,
                "text": dataset[i]["text"],
                "true_label": true,
                "predicted_label": pred
            })

    if not misclassified:
        print(f"✅ [{name}] 모든 예측이 정답입니다!")
        return

    full_path = os.path.join(path_prefix, f"misclassified_{name.lower().replace('-', '_')}.json")
    with open(full_path, "w", encoding="utf-8") as f:
        json.dump(misclassified, f, ensure_ascii=False, indent=2)
    print(f"❗ 오답 로그 저장됨: {full_path}")

# === 평가 함수 ===
def evaluate_model(name, classify_fn, dataset, save_dir):
    y_true, y_pred = [], []
    for item in dataset:
        text, label = item["text"], item["label"]
        pred = classify_fn(text)
        y_true.append(label)
        y_pred.append(pred)
        print(f"[{name}] {text}\n👉 예측: {pred}, ✅ 정답: {label}\n")

    acc = accuracy_score(y_true, y_pred)
    report = classification_report(y_true, y_pred, labels=categories, zero_division=0, output_dict=True)

    # 오답 저장
    save_misclassified_log(name, y_true, y_pred, dataset, path_prefix=save_dir)

    # ✅ Per-class F1 추가 출력
    print(f"\n📊 [{name}] Per-class F1-score:")
    per_class_f1 = {}
    for category in categories:
        f1 = report[category]["f1-score"]
        per_class_f1[category] = f1
        print(f"- {category}: {f1:.3f}")

    return {
        "name": name,
        "accuracy": acc,
        "macro_f1": report["macro avg"]["f1-score"],
        "per_class_f1": per_class_f1
    }

# === 결과 CSV 저장 ===
def save_results_csv(results: list[dict], path="search_backend/experiments/evaluation_result.csv"):
    with open(path, mode="w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["name", "accuracy", "macro_f1"])
        writer.writeheader()
        for row in results:
            writer.writerow({
                "name": row["name"],
                "accuracy": row["accuracy"],
                "macro_f1": row["macro_f1"],
            })
    print(f"📄 성능 결과 저장됨: {path}")

# === Per-class F1 저장 ===
def save_per_class_f1_csv(results: list[dict], path="search_backend/experiments/per_class_f1_result.csv"):
    with open(path, mode="w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["model", "category", "f1_score"])
        for row in results:
            name = row["name"]
            per_class_f1 = row["per_class_f1"]
            for category, f1 in per_class_f1.items():
                writer.writerow([name, category, f1])
    print(f"📄 Per-class F1 결과 저장됨: {path}")

# === 평가셋, 결과 저장 폴더 설정 ===
def make_output_folder(base_path="search_backend/experiments"):
    now = datetime.datetime.now()
    folder_name = now.strftime("%Y%m%d_%H%M%S")  # 예: 20250428_102302
    full_path = os.path.join(base_path, folder_name)
    os.makedirs(full_path, exist_ok=True)
    print(f"📁 결과 저장 폴더 생성됨: {full_path}")
    return full_path

# === 메인 실행 ===
if __name__ == "__main__":
    print("🚀 평가 시작")

    # 1. 저장할 폴더 만들기
    save_dir = make_output_folder()

    # 2. 평가셋 생성 (폴더 안에 저장)
    dataset_path = os.path.join(save_dir, "evaluation_dataset.json")
    dataset = generate_eval_dataset(path=dataset_path)

    # 3. Few-shot 평가
    few_result = evaluate_model("Few-shot", classify_text_with_openai, dataset, save_dir)

    # 4. Zero-shot 평가
    zero_result = evaluate_model("Zero-shot", classify_text_zeroshot, dataset, save_dir)

    # 5. 결과 저장 (폴더 안에 저장)
    save_results_csv([few_result, zero_result], path=os.path.join(save_dir, "evaluation_result.csv"))
    save_per_class_f1_csv([few_result, zero_result], path=os.path.join(save_dir, "per_class_f1_result.csv"))