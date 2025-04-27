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
def generate_eval_dataset(path="fastapi_server/experiments/evaluation_dataset.json"):
    dataset = [
        {"text": "월급이 계속 지연되고 있어요", "label": "임금/퇴직금"},
        {"text": "계약서도 안 쓰고 일만 시켜요", "label": "근로계약"},
        {"text": "야근 수당 안 주는 건 불법 아닌가요?", "label": "근무조건"},
        {"text": "노조 만들었다고 갑자기 다른 부서로 이동했어요", "label": "노동조합"},
        {"text": "출근 중에 교통사고 났는데 치료비를 제가 부담해야 하나요?", "label": "산업재해"},
        {"text": "성희롱 신고했더니 팀장이 더 심하게 괴롭혀요", "label": "직장내성희롱"},
        {"text": "업무 태도 문제로 경고 먹었어요", "label": "부당징계"},
        {"text": "이유 없이 갑자기 내일부터 출근하지 말래요", "label": "부당해고"},
        {"text": "비정규직이라는 이유로 연차도 못 써요", "label": "직장내차별"},
        {"text": "입사한 지 한 달 만에 수습이라고 잘렸어요", "label": "부당해고"},
        {"text": "상사가 외모에 대해 계속 말해요", "label": "직장내성희롱"},
        {"text": "일을 너무 많이 시키고 혼자서 감당이 안 돼요", "label": "직장내괴롭힘"},
        {"text": "수당을 안 주는 건 물론이고, 주휴수당도 몰라요", "label": "근무조건"},
        {"text": "출산휴가 다녀온 뒤 부서가 바뀌었어요", "label": "직장내차별"},
        {"text": "퇴직금이 안 들어왔는데 물어보니 모른다고 해요", "label": "임금/퇴직금"},
        {"text": "징계위원회 없이 바로 정직당했어요", "label": "부당징계"},
        {"text": "계약직인데 계약 연장을 해주지 않겠대요", "label": "근로계약"},
        {"text": "주말마다 나와서 일하는데 수당도 없어요", "label": "근무조건"},
        {"text": "노조에 가입했더니 회식에서도 따돌림당해요", "label": "노동조합"},
        {"text": "출근길 사고인데 산재 처리 못 해준대요", "label": "산업재해"}
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
def save_misclassified_log(name, y_true, y_pred, dataset, path_prefix="fastapi_server/experiments"):
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

    return {
        "name": name,
        "accuracy": acc,
        "macro_f1": report["macro avg"]["f1-score"],
        "micro_f1": report["accuracy"]
    }

# === 결과 CSV 저장 ===
def save_results_csv(results: list[dict], path="fastapi_server/experiments/evaluation_result.csv"):
    with open(path, mode="w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["name", "accuracy", "macro_f1", "micro_f1"])
        writer.writeheader()
        for row in results:
            writer.writerow(row)
    print(f"📄 성능 결과 저장됨: {path}")

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