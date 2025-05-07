const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const GMAIL_USER = functions.config().gmail.user;
const GMAIL_PASS = functions.config().gmail.pass;

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: GMAIL_USER,
    pass: GMAIL_PASS,
  },
});

// ✅ 공통 HTML 템플릿 함수
function createHtmlContent({ userName, date, time, type, isCanceled = false }) {
  const title = isCanceled ? "예약 취소 알림" : "새로운 상담 예약 알림";
  const color = isCanceled ? "#D32F2F" : "#1976D2";
  const highlight = isCanceled ? "❗ 해당 예약이 취소되었습니다." : "📩 새로운 예약이 접수되었습니다.";

  return `
    <div style="font-family: 'Apple SD Gothic Neo', sans-serif; padding: 20px; color: #333;">
      <h2 style="color: ${color}; margin-bottom: 10px;">📌 NomuFinder ${title}</h2>
      <p>안녕하세요, ${userName}님의 상담 내역을 알려드립니다.</p>
      <table style="margin-top: 20px; border-collapse: collapse;">
        <tr>
          <td style="padding: 8px;"><strong>👤 예약자</strong></td>
          <td style="padding: 8px;">${userName}</td>
        </tr>
        <tr>
          <td style="padding: 8px;"><strong>📅 일시</strong></td>
          <td style="padding: 8px;">${date} ${time}</td>
        </tr>
        <tr>
          <td style="padding: 8px;"><strong>💬 방식</strong></td>
          <td style="padding: 8px;">${type} 상담</td>
        </tr>
      </table>
      <p style="margin-top: 30px; font-size: 15px;">${highlight}</p>
      <br />
      <p style="font-size: 13px; color: #999;">- NomuFinder 관리자 드림</p>
    </div>
  `;
}

// 예약 생성 시 이메일
exports.sendReservationEmail = functions.firestore
  .document("reservations/{docId}")
  .onCreate((snap, context) => {
    const data = snap.data();
    console.log("📨 예약 생성 트리거 동작!", data);

    const mailOptions = {
      from: `NomuFinder <${GMAIL_USER}>`,
      to: data.lawyerEmail,
      subject: `[NomuFinder] ${data.userName}님의 예약 알림`,
      html: createHtmlContent({
        userName: data.userName,
        date: data.date,
        time: data.time,
        type: data.type,
        isCanceled: false,
      }),
    };

    return transporter.sendMail(mailOptions)
      .then(() => console.log("✅ 메일 전송 성공"))
      .catch((error) => {
        console.error("❌ 메일 전송 실패:", error);
        throw new Error("메일 전송 실패");
      });
  });

// 예약 취소 시 이메일
exports.sendCancellationEmail = functions.firestore
  .document("reservations/{docId}")
  .onDelete((snap, context) => {
    const data = snap.data();
    console.log("📨 예약 취소 트리거 동작!", data);

    const mailOptions = {
      from: `NomuFinder <${GMAIL_USER}>`,
      to: data.lawyerEmail,
      subject: `[취소됨][NomuFinder] ${data.userName}님의 예약`,
      html: createHtmlContent({
        userName: data.userName,
        date: data.date,
        time: data.time,
        type: data.type,
        isCanceled: true,
      }),
    };

    return transporter.sendMail(mailOptions)
      .then(() => console.log("✅ 메일 전송 성공"))
      .catch((error) => {
        console.error("❌ 메일 전송 실패:", error);
        throw new Error("메일 전송 실패");
      });
  });