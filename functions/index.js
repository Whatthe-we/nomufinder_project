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
function createHtmlContent({ userName, date, time, type, phone, isCanceled = false }) {
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
          <td style="padding: 8px;"><strong>📱 연락처</strong></td>
          <td style="padding: 8px;">${phone}</td>
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
        phone: data.phone, // ✅ 추가
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
        phone: data.phone, // ✅ 추가
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
  const { google } = require('firebase-admin'); // Cloud Tasks 사용을 위해 추가 (이미 있다면 생략)

  // ✅ 예약 24시간 전 알림 (Cloud Tasks 트리거)
  exports.sendScheduledReservationReminder = functions.https.onRequest(async (req, res) => {
    const { userId, reservationTime, userName } = req.body;
    const parsedReservationTime = new Date(reservationTime);

    await sendNotification(userId, parsedReservationTime, userName);
    res.status(200).send('예약 알림 발송 완료');
  });

  // ✅ 예약 생성 시 24시간 전 알림 스케줄링
  exports.sendReservationReminderOnCreate = functions.firestore
    .document('reservations/{reservationId}')
    .onCreate(async (snapshot, context) => {
      const reservationData = snapshot.data();

      if (!reservationData || !reservationData.date || !reservationData.userName || !reservationData.userId) {
        console.log('필수 예약 정보가 없습니다.');
        return null;
      }

      const reservationTime = reservationData.date.toDate();
      const now = new Date();
      const timeDifference = reservationTime.getTime() - now.getTime();
      const oneDayInMilliseconds = 24 * 60 * 60 * 1000;

      const userId = reservationData.userId;

      if (timeDifference <= oneDayInMilliseconds) {
        console.log('예약 시간이 24시간 이내이므로 즉시 알림을 보냅니다.');
        return sendNotification(userId, reservationTime, reservationData.userName);
      } else {
        const reminderTime = new Date(reservationTime.getTime() - oneDayInMilliseconds);
        const scheduleTime = `${reminderTime.getMinutes()} ${reminderTime.getHours()} ${reminderTime.getDate()} ${reminderTime.getMonth() + 1} *`;

        console.log(`알림 예약: ${reminderTime.toLocaleString()} (Cron: ${scheduleTime})`);

        const cloudTasks = google.cloud.tasks('v2');
        const parent = cloudTasks.queuePath(functions.config().project.location, 'reservation-reminders');
        const task = {
          scheduleTime: {
            seconds: reminderTime.getTime() / 1000,
          },
          httpRequest: {
            httpMethod: 'POST',
            url: `https://${functions.config().project.region}-${functions.config().project.name}.cloudfunctions.net/sendScheduledReservationReminder`,
            body: Buffer.from(JSON.stringify({ userId: userId, reservationTime: reservationTime.toISOString(), userName: reservationData.userName })).toString('base64'),
            headers: {
              'Content-Type': 'application/json',
            },
            oidcToken: {
              serviceAccountEmail: `${functions.config().project.name}@${functions.config().project.app}.iam.gserviceaccount.com`,
            },
          },
        };

        try {
          const [response] = await cloudTasks.createTask({ parent: parent, task: task });
          console.log('Cloud Task 생성 완료:', response);
          return null;
        } catch (error) {
          console.error('Cloud Task 생성 실패:', error);
          return null;
        }
      }
    });

  async function sendNotification(userId, reservationTime, userName) {
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    if (!userDoc.exists || !userDoc.data().fcmToken) {
      console.log('해당 사용자의 FCM 토큰을 찾을 수 없습니다:', userId);
      return null;
    }

    const fcmToken = userDoc.data().fcmToken;
    const payload = {
      notification: {
        title: '예약 알림',
        body: `${userName}님, ${reservationTime.toLocaleString()} 예약이 곧 시작됩니다.`,
      },
    };

    try {
      const response = await admin.messaging().sendToDevice(fcmToken, payload);
      console.log('FCM 메시지 전송 성공:', response);
      return null;
    } catch (error) {
      console.error('FCM 메시지 전송 실패:', error);
      return null;
    }
  }