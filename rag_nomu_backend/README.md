# rag_nomu_backend

## ✅ 백엔드 실행 방법

```bash
# --- ✅ Windows 기준 ---
# 1. 가상환경 세팅
cd nomufinder_project/rag_nomu_backend
python -m venv venv
venv\Scripts\activate # 프롬프트가 (venv)로 바뀌면 성공!

# 2. 패키지 설치 (Python 3.10 환경이어야 함 !!)
pip install -r requirements.txt
pip list # 설치된 버전 확인

# 3. 환경 변수 설정
.env 생성 및 수정

# 4. 실행
uvicorn main:app --reload --port 8000
http://127.0.0.1:8000 # 브라우저에서 연결 확인

# 5. 비활성화
deactivate

# --- ✅ macOS 기준 ---
# 1. 가상환경 세팅
cd nomufinder_project/rag_nomu_backend
python3 -m venv venv
source venv/bin/activate # 프롬프트가 (venv)로 바뀌면 성공!

# 2. 패키지 설치 (Python 3.10 환경이어야 함 !!)
pip install -r requirements.txt
pip list # 설치된 버전 확인

# 3. 환경 변수 설정
.env 생성 및 수정

# 4. 실행
uvicorn main:app --reload --port 8000
http://127.0.0.1:8000 # 브라우저에서 연결 확인

# 5. 비활성화
deactivate