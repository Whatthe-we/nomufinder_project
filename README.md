<p align="center">
  <img src="https://github.com/Whatthe-we/nomufinder_project/blob/main/assets/images/README_1.png?raw=true" width="800">
</p>

# 노무파인더 (NomuFinder)

**노무파인더**는 다음과 같은 고민에서 출발한 프로젝트입니다 :

* 노동 문제를 겪었을 때, 어디에 물어봐야 할지 모르겠다.
* 내가 겪는 문제가 부당해고인지, 임금체불인지 판단하기 어렵다.
* 노무사를 직접 찾아 상담하고 예약하는 과정이 복잡하고 불편하다.
  

이러한 문제를 해결하기 위해,<br>**🤠 NOMAD 팀**은 AI 기반 노동 상담 플랫폼 ‘노무파인더’를 개발하였습니다.

노무파인더는 **사용자의 상황을 AI가 먼저 파악**하고, 그에 가장 적합한 **공인노무사(CPLA)를 연결**해주는 모바일 플랫폼입니다.

<p align="center">
  <img src="https://github.com/Whatthe-we/nomufinder_project/blob/main/assets/images/README_2.gif?raw=true" width="250">
</p>

---

## 사용자 흐름 (User Flow)
1. **고민 입력**  
   사용자는 자연어 문장으로 상황을 입력합니다.

2. **AI 분류 및 키워드 추천**  
   GPT가 문장을 분석해 카테고리를 분류하고, 관련 키워드를 자동 추천합니다.

3. **노무사 리스트 조회 및 필터링**  
   필터(지역, 성별 등)를 적용하여 적절한 노무사를 탐색합니다.
   <sub>※ 노무사 정보는 가상 정보(이름/성별/소속/이메일/전문 분야)를 추가한 테스트용 더미 데이터셋을 사용하였습니다.</sub>

5. **상담 예약 진행**  
   날짜, 시간, 방식(전화/영상/방문)을 선택하고 예약합니다.
   예약 결과는 이메일로 자동 안내됩니다.

6. **챗봇 상담**  
   추가 상담이 필요할 경우, RAG 기반 챗봇을 통해 보충 질문이 가능합니다.
   
---

## 주요 기능
- 💬 LangChain 기반 RAG 챗봇 상담
- 🤖 GPT 기반 노동 문제 자동 분류 (Few-shot prompting)
- 🧠 GPT 기반 자동완성 키워드 추천
- 👨‍⚖️ 사용자 맞춤형 노무사 필터링 및 리스트 출력
- 📆 캘린더 기반 노무 상담 예약 기능
- 📩 MailerSend 기반 예약 알림 이메일 전송
- 📺 YouTube API 연동을 통한 노동 교육 콘텐츠 제공
- 🔒 Firebase Auth 기반 로그인 및 마이페이지 관리

---

## 기술 스택

| 항목 | 기술 |
|------|-----------|
| Frontend |    Flutter, Riverpod, GoRouter    |
| Backend | FastAPI, Firebase (Firestore, Realtime DB, Functions) |
| Auth & Push | Firebase Auth, FCM |
| AI | OpenAI GPT, LangChain, Gemini (Google AI) |
| Infra | Firebase Hosting, GitHub |
| 외부 API | YouTube, Google Maps, Google Calendar |
| Design | Figma |

---

## 디렉토리 구조 요약

```
nomufinder/
│
├── lib/                    # Flutter 앱 소스
│   ├── screens/           # 온보딩, 검색, 예약, 챗봇 등 주요 화면
│   ├── viewmodels/        # 상태 관리 (Riverpod)
│   ├── services/          # FastAPI, Firebase, YouTube 등 연동 서비스
│   ├── models/            # 유저, 예약, 리뷰 등 데이터 모델
│   ├── widgets/           # 공통 UI 컴포넌트
│   ├── config/, utils/    # 라우터, 상수, 유틸 함수 등
│
├── search_backend/        # GPT 기반 카테고리 분류기 및 예약 API
├── rag_nomu_backend/      # LangChain 기반 RAG 챗봇 서버
├── functions/             # Firebase 예약 알림 이메일 함수
├── test/                  # 위젯 및 화면 단위 테스트
├── pubspec.yaml           # Flutter 의존성 정의
└── README.md
```
---
## RAG System
<p align="center">
  <img src="https://github.com/Whatthe-we/nomufinder_project/blob/main/assets/images/rag1.png?raw=true" width="800">
</p>

## RAG 전체 흐름

1️⃣ 사용자 질문 또는 진술 입력
사용자가 챗봇에 텍스트(질문 또는 진술)를 입력하면, 해당 데이터는 Firebase의 /chat_questions 경로에 저장됩니다.

2️⃣ FastAPI Listener가 요청 수신
FastAPI 서버가 Firebase를 감지하여 새로운 입력이 들어오면 이를 서버로 가져옵니다.

3️⃣ 문장 분류: 진술 vs 질문
classify_need_for_question 함수를 통해 입력된 문장이 ‘질문’인지 ‘진술’인지 판단합니다.

4️⃣ 분류 결과에 따른 흐름 분기
🔹 질문일 경우
질문을 그대로 유지합니다.

→ Query 구성을 통해 검색에 적합한 쿼리를 만듭니다.

→ 이 쿼리를 사용하여 RAG 파이프라인이 실행됩니다.

🔸 진술일 경우
사용자의 진술에서 적절한 후속 질문을 생성합니다.
예: “나는 퇴사했어요” → “퇴사 사유는 무엇인가요?”

생성된 질문은 query 구성 단계를 거치지 않고,
곧바로 RAG 파이프라인으로 넘어가 답변을 생성합니다.

🔁 이 구조는 진술 → 질문 생성 → 응답 생성이라는 빠른 흐름을 만듭니다.
즉, 진술 입력 시에는 검색 최적화나 별도 Query 구성 없이 바로 응답을 생성합니다.

5️⃣ RAG Pipeline 실행
FAISS Index: 문서 임베딩 및 청킹된 인덱스를 활용합니다.

Hybrid Retriever (FAISS + BM25): 문맥 검색 수행.

Context 반환 → GPT-4.1을 통해 문맥 기반 응답 생성.

RAG Chain에서 전체 프로세스를 통합 실행.

6️⃣ 응답 결과 저장 및 사용자 전달
생성된 응답은 Firebase /chat_answers 경로에 저장되고,

챗봇 UI를 통해 사용자에게 결과가 전달됩니다.



---

## 실행 방법 요약
### Flutter 앱 실행

```bash
flutter pub get
flutter run
```

### FastAPI 분류 서버 실행 (8001)

```bash
cd search_backend/
uvicorn main:app --host 0.0.0.0 --port 8001
```

### RAG 챗봇 서버 실행 (8000)

```bash
cd rag_nomu_backend/
uvicorn main:app --host 0.0.0.0 --port 8000
```

### Firebase Functions 배포

```bash
cd functions/
firebase deploy --only functions
```

---

## 라이선스

MIT License © 2025 NOMAD Team (Eunsol Lee, Myeongji Ko, Yujin Choi)
