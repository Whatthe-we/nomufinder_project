<p align="center">
  <img src="https://github.com/Whatthe-we/nomufinder_project/blob/main/assets/images/README_1.png?raw=true" width="800">
</p>

# 노무파인더 (NomuFinder)

[English](README.md) | 한글

노무파인더는 다음과 같은 고민에서 출발한 프로젝트입니다:

* 노동 문제를 겪었을 때, 어디에 물어봐야 할지 모르겠다.
* 내가 겪는 문제가 부당해고인지, 임금체불인지 판단이 어렵다.
* 노무사를 직접 찾아 상담하고 예약하는 과정이 복잡하고 불편하다.

그래서,
우리는 AI와 공인노무사(CPLA)가 함께 돕는 AI 기반 노동 상담 플랫폼 **노무파인더**를 제작하였습니다.  
AI가 사용자의 상황을 이해하고, 맞춤형 노무사를 매칭해주는 앱입니다.

<p align="center">
    <img src="https://github.com/mycalls/applimode-examples/blob/main/assets/am-preview-480p-10f-240829.gif?raw=true" width="320">
</p>

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
|    Frontend    |    Flutter, Riverpod, GoRouter    |
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
* [CODE WITH ANDREA](https://codewithandrea.com/) _ 수정 필요
* [Riverpod](https://riverpod.dev/) _ 수정 필요

---
* ## 라이선스

MIT License © 2025 NomuFinder Team
