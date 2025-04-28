from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional

router = APIRouter()

class ReservationRequest(BaseModel):
    lawyerEmail: str
    lawyerName: str
    userName: str
    date: str
    time: str
    type: str
    isCanceled: Optional[bool] = False  # ✅ 여기에 추가!

@router.post("/send-reservation-email")
async def send_reservation_alert(reservation: ReservationRequest):
    try:
        print("📥 이메일 요청 도착:", reservation)

        # ❌ 아래 메일 전송 호출 제거 (Cloud Functions에서 자동 처리함)
        # send_reservation_email(
        #     to_email=reservation.lawyerEmail,
        #     lawyer_name=reservation.lawyerName,
        #     user_name=reservation.userName,
        #     date=reservation.date[:10],
        #     time=reservation.time,
        #     method=reservation.type,
        #     is_canceled=reservation.isCanceled,
        # )

        return {"success": True}
    except Exception as e:
        print("❌ 이메일 전송 실패:", e)
        return {"success": False, "error": str(e)}