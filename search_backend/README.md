# 🧠 Few-shot Prompting 기반 노동문제 분류 실험

## ✅ 실험 개요
- 사용자 자연어 입력을 기반으로 GPT가 노동 문제 유형을 분류하는 AI 분류기 구현
- Zero-shot보다 높은 분류 정확도를 위해 **Few-shot Prompting** 기법을 적용
- 문체 유형(business / worker / casual) 및 복합 쟁점 구분을 고려한 프롬프트 구성
- 예시 문장 튜닝 및 키워드 매칭을 통한 정밀도 향상

---

## 📋 실험 조건

| 항목 | 내용 |
|------|------|
| 대상 카테고리 | 총 13개 (부당해고, 산업재해, 임금체불 등) |
| 모델 | OpenAI GPT 기반 |
| 방식 | Zero-shot vs Few-shot Prompt 비교 |
| 평가 지표 | Accuracy, Macro F1 Score, Category별 F1 Score |

---

## 🧪 실험 결과 비교 (Zero-shot vs Few-shot)

### 🔹 **1차 실험 (기초 프롬프트 구성)**  
![1차 실험](./images/최종_1차_final_test_f1_comparison.png)

### 🔹 **2차 실험 (핵심 오답 보완)**  
![2차 실험](./images/최종_2차_final_test_f1_comparison.png)

### 🔹 **3차 실험 (카테고리별 키워드 + 문체 대응)**  
![3차 실험](./images/최종_3차_final_test_f1_comparison.png)

> 🔍 대부분의 카테고리에서 Few-shot 방식이 Zero-shot보다 더 높은 F1 Score를 기록하였으며,  
> 특히 `기업자문`, `컨설팅`과 같은 구분이 어려운 항목에서 **큰 성능 차이**를 보였습니다.

---

## 📌 기술 포인트

- 💡 사용자 문장에서 핵심 키워드를 추출하고, Few-shot 예시와 함께 GPT에게 분류 요청
- ✅ 예: `'산업재해' vs '출퇴근 재해'`처럼 유사한 이슈를 구별하여 **적합한 키워드 우선 추천**
- 🛠 프롬프트 설계에는 역할 설정, 명확한 출력 지시, 예시 문장 튜닝 전략이 포함됨

---

## 📁 관련 코드

- `classifier.py`: GPT 기반 분류기
- `fewshot_examples.json`: 카테고리별 Few-shot 예시
- `evaluate_f1.py`: F1 score 계산 스크립트
- `charts/`: 실험 결과 시각화 이미지

---