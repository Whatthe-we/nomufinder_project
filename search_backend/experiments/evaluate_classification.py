import json
import sys
import csv
import os
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
        {"text": "수습 끝나자마자 나가라고 통보 받았어요", "label": "부당해고"},
        {"text": "이유를 듣지도 못했는데 정직 당했어요", "label": "부당징계"},
        {"text": "정당한 사유가 없는데 계약 종료 하겠대요", "label": "부당해고"},
        {"text": "제 잘못을 소명할 기회 없이 감봉 조치 받았습니다", "label": "부당징계"},
        {"text": "회사에서 경고를 계속 줘요", "label": "부당징계"},
        # 부당해고&부당징계 - 사업주
        {"text": "수습 기간 중 실력이 부족한 사원은 내보낼 수 있나요?", "label": "부당해고"},
        {"text": "직원의 불성실한 근태로 인한 징계 절차가 궁금합니다", "label": "부당징계"},
        {"text": "계약 만료 후 재계약 거절은 부당해고인가요?", "label": "부당해고"},
        {"text": "경고 조치를 할 때 주의할 점이 있나요?", "label": "부당징계"},
        {"text": "정직 처분 시 필요한 사전 절차는 무엇인가요?", "label": "부당징계"},

        # 근로계약&근무조건 - 근로자
        {"text": "근로계약서를 작성하지 않았어요", "label": "근로계약"},
        {"text": "주 60시간 넘게 일하고 있어요", "label": "근무조건"},
        {"text": "연차를 쓸 수 없게 막아요", "label": "근무조건"},
        {"text": "근로계약 내용과 실제 근로조건이 달라요", "label": "근로계약"},
        {"text": "수습 기간이라고 급여를 적게 주네요", "label": "근로계약"},
        # 근로계약&근무조건 - 사업주
        {"text": "근로계약서는 언제까지 작성해야 하나요?", "label": "근로계약"},
        {"text": "연장근로 시 수당 지급 기준은 뭔가요?", "label": "근무조건"},
        {"text": "수습 기간 급여를 조정할 수 있나요?", "label": "근로계약"},
        {"text": "연차 사용을 회사가 지정할 수 있나요?", "label": "근무조건"},
        {"text": "근로시간 단축 요청을 거부해도 되나요?", "label": "근무조건"},

        # 직장내성희롱&괴롭힘 - 근로자
        {"text": "상사가 외모를 지적했어요", "label": "직장내성희롱"},
        {"text": "성희롱 신고 이후 보복을 당했어요", "label": "직장내성희롱"},
        {"text": "괴롭힘으로 인해 퇴사하고 싶은데 실업급여 받을 수 있나요?", "label": "직장내괴롭힘"},
        {"text": "상사가 욕설을 합니다", "label": "직장내괴롭힘"},
        {"text": "집단 따돌림을 당하고 있어요", "label": "직장내괴롭힘"},
        # 직장내성희롱&괴롭힘 - 사업주
        {"text": "성희롱 예방교육을 꼭 해야 하나요?", "label": "직장내성희롱"},
        {"text": "직장 내 괴롭힘 신고 접수 시 조치 방법은?", "label": "직장내괴롭힘"},
        {"text": "성희롱 신고가 거짓일 경우 대응은?", "label": "직장내성희롱"},
        {"text": "직장 내 괴롭힘 가해자 징계 절차는?", "label": "직장내괴롭힘"},
        {"text": "직장 내 따돌림 조사 방법이 궁금합니다", "label": "직장내괴롭힘"},

        # 직장내차별 - 근로자
        {"text": "출산휴가 다녀왔더니 부서가 바뀌었어요", "label": "직장내차별"},
        {"text": "비정규직이라 연차를 못 써요", "label": "직장내차별"},
        {"text": "육아휴직 복귀 후 불이익을 당했어요", "label": "직장내차별"},
        {"text": "나이 때문에 승진이 안 된 것 같아요", "label": "직장내차별"},
        {"text": "장애인 차별을 경험했어요", "label": "직장내차별"},
        # 직장내차별 - 사업주
        {"text": "출산휴가 복귀자 인사이동 가능한가요?", "label": "직장내차별"},
        {"text": "비정규직 연차 부여 기준이 궁금합니다", "label": "직장내차별"},
        {"text": "육아휴직 후 다른 부서 배치해도 되나요?", "label": "직장내차별"},
        {"text": "정년퇴직자 재고용 의무가 있나요?", "label": "직장내차별"},
        {"text": "장애인 의무고용 비율 미달 시 불이익은?", "label": "직장내차별"},

        # 임금/퇴직금 - 근로자
        {"text": "퇴직금 정산이 늦어지고 있어요", "label": "임금/퇴직금"},
        {"text": "월급이 정해진 날짜에 안 들어와요", "label": "임금/퇴직금"},
        {"text": "수습 기간 동안 최저임금도 못 받았어요", "label": "임금/퇴직금"},
        {"text": "퇴사 후 임금이 체불됐어요", "label": "임금/퇴직금"},
        {"text": "퇴직금이 적게 나왔어요", "label": "임금/퇴직금"},
        # 임금/퇴직금 - 사업주
        {"text": "퇴직금 지급 시기와 방법이 궁금합니다", "label": "임금/퇴직금"},
        {"text": "임금 체불 시 법적 책임은 어떻게 되나요?", "label": "임금/퇴직금"},
        {"text": "퇴직금 계산 기준을 알고 싶어요", "label": "임금/퇴직금"},
        {"text": "수습 해고 시 임금 지급 의무가 있나요?", "label": "임금/퇴직금"},
        {"text": "퇴직금 중간정산 가능한가요?", "label": "임금/퇴직금"},

        # 산업재해 - 근로자
        {"text": "출근길 교통사고 산재 처리 가능할까요?", "label": "산업재해"},
        {"text": "업무 중 허리를 다쳤는데 산재 신청 가능한가요?", "label": "산업재해"},
        {"text": "산재 신청했더니 회사에서 싫어해요", "label": "산업재해"},
        {"text": "작업 중 다쳤는데 병원비가 걱정돼요", "label": "산업재해"},
        {"text": "야근하다 사고를 당했어요", "label": "산업재해"},
        # 산업재해 - 사업주
        {"text": "산재 신청을 회사가 거부할 수 있나요?", "label": "산업재해"},
        {"text": "업무상 재해 인정 기준이 궁금합니다", "label": "산업재해"},
        {"text": "산재 처리 시 회사 책임 범위는?", "label": "산업재해"},
        {"text": "출퇴근 사고도 산재로 인정되나요?", "label": "산업재해"},
        {"text": "산재 예방 조치를 못 하면 어떤 처벌을 받나요?", "label": "산업재해"},

        # 노동조합 - 근로자
        {"text": "노조 가입한다고 했더니 괴롭힘을 당해요", "label": "노동조합"},
        {"text": "노조 활동 때문에 인사 불이익을 받았어요", "label": "노동조합"},
        {"text": "노조 가입비는 반드시 내야 하나요?", "label": "노동조합"},
        {"text": "노조 가입을 이유로 부당전출 당했어요", "label": "노동조합"},
        {"text": "파업에 참가하면 징계당할 수 있나요?", "label": "노동조합"},
        # 노동조합 - 사업주
        {"text": "교섭대표노조와의 교섭 방법이 궁금합니다", "label": "노동조합"},
        {"text": "노조 활동을 이유로 해고하면 불법인가요?", "label": "노동조합"},
        {"text": "복수노조 대응 방법이 필요합니다", "label": "노동조합"},
        {"text": "노조 파업 시 임금 지급 의무가 있나요?", "label": "노동조합"},
        {"text": "노동조합에 협박성 요구를 받을 때 어떻게 하나요?", "label": "노동조합"},

        # 기업자문 - 사업주
        {"text": "취업규칙 개정할 때 필요한 절차는?", "label": "기업자문"},
        {"text": "근로시간 유연하게 조정하려면 어떻게 해야 하나요?", "label": "기업자문"},
        {"text": "인사규정 새로 정비하고 싶습니다", "label": "기업자문"},
        {"text": "노무 리스크 예방을 위한 점검 방법은?", "label": "기업자문"},
        {"text": "직장 내 괴롭힘 예방 매뉴얼 작성 방법은?", "label": "기업자문"},
        {"text": "근로감독 대비 준비할 수 있는 게 뭔가요?", "label": "기업자문"},
        {"text": "정리해고 진행 시 필수 절차가 있나요?", "label": "기업자문"},
        {"text": "징계 규정 업데이트 방법이 궁금합니다", "label": "기업자문"},
        {"text": "근로자대표 선출 절차가 필요할까요?", "label": "기업자문"},
        {"text": "신규 입사자 교육 자료를 준비하려면?", "label": "기업자문"},

        # 컨설팅 - 사업주
        {"text": "인사평가 제도 컨설팅을 받고 싶어요", "label": "컨설팅"},
        {"text": "성과급 제도를 도입하고 싶은데 방법은?", "label": "컨설팅"},
        {"text": "조직문화 진단 컨설팅 받고 싶습니다", "label": "컨설팅"},
        {"text": "ESG 경영 컨설팅 대상이 궁금합니다", "label": "컨설팅"},
        {"text": "임금피크제 도입 컨설팅 받고 싶어요", "label": "컨설팅"},
        {"text": "직무분석 컨설팅 절차가 궁금해요", "label": "컨설팅"},
        {"text": "채용 컨설팅을 통해 공정성 확보가 가능한가요?", "label": "컨설팅"},
        {"text": "4대보험 정산 컨설팅도 가능한가요?", "label": "컨설팅"},
        {"text": "임금체계 개편 컨설팅 받고 싶어요", "label": "컨설팅"},
        {"text": "노사관계 개선 컨설팅을 받고 싶어요", "label": "컨설팅"},

        # 급여아웃소싱 - 사업주
        {"text": "급여 아웃소싱을 맡기면 어떤 이점이 있나요?", "label": "급여아웃소싱"},
        {"text": "급여 대행 서비스 이용 비용은 얼마나 하나요?", "label": "급여아웃소싱"},
        {"text": "퇴직금 정산까지 맡길 수 있나요?", "label": "급여아웃소싱"},
        {"text": "4대보험 신고도 급여 대행에서 해주나요?", "label": "급여아웃소싱"},
        {"text": "급여명세서 발송은 어떻게 처리되나요?", "label": "급여아웃소싱"},
        {"text": "급여 이체는 자동으로 이뤄지나요?", "label": "급여아웃소싱"},
        {"text": "비정규직 급여 계산도 대행 가능한가요?", "label": "급여아웃소싱"},
        {"text": "급여자료 제공 방식은 어떻게 되나요?", "label": "급여아웃소싱"},
        {"text": "급여 대행 업체 선정 시 주의할 점은?", "label": "급여아웃소싱"},
        {"text": "퇴직 연금 처리도 대행 해주나요?", "label": "급여아웃소싱"}
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
def evaluate_model(name, classify_fn, dataset):
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
    save_misclassified_log(name, y_true, y_pred, dataset)

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
        "per_class_f1": per_class_f1  # ✅ 추가!!
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

# === 메인 실행 ===
if __name__ == "__main__":
    print("🚀 평가 시작")
    dataset = generate_eval_dataset()

    # Few-shot
    few_result = evaluate_model("Few-shot", classify_text_with_openai, dataset)

    # Zero-shot
    zero_result = evaluate_model("Zero-shot", classify_text_zeroshot, dataset)

    # 저장
    save_results_csv([few_result, zero_result])
    save_per_class_f1_csv([few_result, zero_result])  # ✅ 추가