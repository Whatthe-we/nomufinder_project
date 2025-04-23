import os
from mailersend import emails
from dotenv import load_dotenv

# 환경 변수 로딩
load_dotenv()
print("📨 MAILERSEND_FROM_EMAIL:", os.getenv("MAILERSEND_FROM_EMAIL"))

# MailerSend 클라이언트 초기화
mailer = emails.NewEmail()
mailer.api_key = os.getenv("MAILERSEND_API_KEY")

# ✅ 예약 알림 이메일 전송 함수
def send_reservation_email(
    to_email: str,
    lawyer_name: str,
    user_name: str,
    date: str,
    time: str,
    method: str,
    is_canceled: bool = False  # ← 예약 취소 여부 추가
):
    # 제목과 본문 구분
    subject_prefix = "[취소됨] " if is_canceled else ""
    subject = f"{subject_prefix}[NomuFinder] {user_name}님의 예약 알림"

    body = f"""안녕하세요, {lawyer_name} 노무사님.

▶ 예약자: {user_name}
▶ 일시: {date} {time}
▶ 상담 방식: {method}

{'❗ 이 예약은 사용자가 취소했습니다.' if is_canceled else '📅 새로운 예약이 접수되었습니다.'}

NomuFinder 관리자 드림
"""

    try:
        mailer.send(
            {
                "from": {
                    "email": os.getenv("MAILERSEND_FROM_EMAIL"),
                    "name": "NomuFinder"
                },
                "to": [{"email": to_email}],
                "subject": subject,
                "text": body
            }
        )
        print("✅ 메일 전송 성공")
    except Exception as e:
        print("❌ 메일 전송 실패:", e)