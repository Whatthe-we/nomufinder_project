import json
import sys
import os
import csv
from dotenv import load_dotenv
from openai import OpenAI
import matplotlib.font_manager as fm
import matplotlib.pyplot as plt
from sklearn.metrics import classification_report, accuracy_score

# 경로 추가
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from classifier import classify_text_with_openai, clean_category_output, categories

# Load API Key
load_dotenv()
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
classify_text_with_openai.__globals__["client"] = client

# 한글 폰트 설정 (Windows용)
plt.rcParams['font.family'] = 'Malgun Gothic'
plt.rcParams['axes.unicode_minus'] = False     # 마이너스 부호 깨짐 방지

# === Zero-shot 함수 ===
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

# === 평가 함수 ===
def evaluate_model(name, classify_fn, dataset):
    y_true, y_pred = [], []
    for item in dataset:
        text, label = item["text"], item["label"]
        pred = classify_fn(text)
        y_true.append(label)
        y_pred.append(pred)
        print(f"[{name}] 문장: {text}\n👉 예측: {pred} / ✅ 정답: {label}\n")

    acc = accuracy_score(y_true, y_pred)
    report = classification_report(y_true, y_pred, labels=categories, zero_division=0, output_dict=True)
    return {"name": name, "accuracy": acc, "report": report}

# === 테스트 실행 ===
with open("search_backend/experiments/test_set.json", "r", encoding="utf-8") as f:
    test_set = json.load(f)

results = [
    evaluate_model("Few-shot", classify_text_with_openai, test_set),
    evaluate_model("Zero-shot", classify_text_zeroshot, test_set),
]

# === csv 저장 ===
csv_path = os.path.join("search_backend", "experiments", "final_test_results.csv")
with open(csv_path, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["Category", "Few-shot F1", "Zero-shot F1"])
    for i, cat in enumerate(categories):
        few_f1 = results[0]["report"][cat]["f1-score"]
        zero_f1 = results[1]["report"][cat]["f1-score"]
        writer.writerow([cat, few_f1, zero_f1])
print(f"📄 결과 CSV 저장됨: {csv_path}")

# === 그래프 시각화 ===
plt.figure(figsize=(12, 6))
x = range(len(categories))
for result in results:
    f1_scores = [result["report"][cat]["f1-score"] for cat in categories]
    plt.plot(x, f1_scores, marker="o", label=result["name"])

    # 점 위에 텍스트로 f1-score 표시
    for i, score in enumerate(f1_scores):
        plt.text(i, score + 0.01, f"{score:.2f}", ha='center', va='bottom', fontsize=9)

plt.xticks(x, categories, rotation=45, ha="right")
plt.title("Few-shot vs Zero-shot")
plt.xlabel("Category")
plt.ylabel("F1 Score")
plt.legend()
plt.grid(True)
plt.tight_layout()

img_path = os.path.join("search_backend", "experiments", "final_test_f1_comparison.png")
plt.savefig(img_path, dpi=300)
print(f"📁 그래프 저장됨: {img_path}")
plt.show()