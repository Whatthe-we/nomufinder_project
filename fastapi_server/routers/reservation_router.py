from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
from email_service import send_reservation_email

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
        send_reservation_email(
            to_email=reservation.lawyerEmail,
            lawyer_name=reservation.lawyerName,
            user_name=reservation.userName,
            date=reservation.date[:10],
            time=reservation.time,
            method=reservation.type,
            is_canceled=reservation.isCanceled,  # ✅ 이렇게 FastAPI 함수에 넘김
        )
        return {"success": True}
    except Exception as e:
        print("❌ 이메일 전송 실패:", e)
        return {"success": False, "error": str(e)}