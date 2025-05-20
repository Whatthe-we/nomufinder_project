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

4. **상담 예약 진행**  
   날짜, 시간, 방식(전화/영상/방문)을 선택하고 예약합니다.
   예약 결과는 이메일로 자동 안내됩니다.

5. **챗봇 상담**  
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

<p align="center">
  <img src="https://github.com/Whatthe-we/nomufinder_project/blob/main/assets/images/rag1.png?raw=true" width="800">
</p>

## RAG System

✅ 1. 유저 질문 입력
사용자가 질문(또는 진술)을 입력하면, 이 정보는 Firebase의 /chat_questions 경로에 저장됩니다.

✅ 2. FastAPI Listener 동작
FastAPI 서버가 Firebase를 실시간으로 감지하고 새로운 질문이 들어오면 이를 가져와 처리합니다.

✅ 3. 질문 분류
입력된 문장이 "진술인지 질문인지"를 판별하기 위해
classify_need_for_question 함수를 통해 문장 유형을 분류합니다.

진술: ex) "나는 퇴사했어요"

질문: ex) "퇴사하면 퇴직금 받을 수 있나요?"

✅ 4. 분류 결과에 따른 처리
진술일 경우:

후속 질문을 생성합니다. (예: “퇴사한 시기는 언제인가요?”)

이렇게 생성된 질문이 Query 구성 단계로 넘어갑니다.

질문일 경우:

질문을 그대로 유지하여 Query 구성 단계로 바로 넘어갑니다.

✅ 5. Query 구성
사용자의 입력 또는 생성된 후속 질문을 기반으로 RAG 시스템에서 사용할 Query를 구성합니다.

✅ 6. RAG Pipeline 실행
Query를 기반으로 다음 과정을 순차적으로 진행합니다:

FAISS Index (Chunking + Embedding)

미리 준비된 문서를 쪼개고 임베딩하여 벡터 인덱스를 구성해둔 상태입니다.

Hybrid Retriever (FAISS + BM25)

쿼리를 기반으로 하이브리드 검색(벡터 기반 + 키워드 기반)을 수행하여 관련 문맥(Context)을 반환합니다.

LLM (GPT-4.1)

검색된 문맥을 기반으로 GPT-4.1 모델이 답변을 생성합니다.

RAG Chain

전체 검색-생성 과정을 하나의 체인으로 구성하여 최종 응답을 생성합니다.

✅ 7. 응답 결과 저장
생성된 응답 결과는 다시 Firebase의 /chat_answers 경로에 저장됩니다.

✅ 8. 사용자에게 응답 전달
사용자는 챗봇 인터페이스를 통해 최종 응답을 확인할 수 있습니다.



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

## 감사의 말
노무파인더 개발에 많은 도움을 준 다음 프로젝트에 특별히 감사드립니다.

---

## 라이선스

MIT License © 2025 NOMAD Team (Eunsol Lee, Myeongji Ko, Yujin Choi)
