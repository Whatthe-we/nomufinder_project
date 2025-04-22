import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class ReservationViewModel {
  final _collection = FirebaseFirestore.instance.collection('reservations');

  /// 예약 저장
  Future<void> saveReservation({
    required String lawyerId,
    required String lawyerName,
    required String lawyerEmail,
    required DateTime date,
    required String time,
    required String type,
    required String userName,
    required String userPhone,
  }) async {
    final reservation = {
      'lawyerId': lawyerId,
      'lawyerName': lawyerName,
      'lawyerEmail': lawyerEmail,
      'date': date.toIso8601String(),
      'time': time,
      'type': type,
      'userName': userName,
      'userPhone': userPhone,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _collection.add(reservation);
  }

  /// 예약된 날짜 + 시간 조합 (예약 화면 비활성화용)
  Future<Map<String, List<String>>> getReservedDateTimes(String lawyerId) async {
    final snapshot = await _collection.where('lawyerId', isEqualTo: lawyerId).get();

    Map<String, List<String>> reservedMap = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final dateStr = data['date']?.substring(0, 10);
      final time = data['time'];
      if (dateStr != null && time != null) {
        reservedMap.putIfAbsent(dateStr, () => []).add(time);
      }
    }

    return reservedMap;
  }

  /// 내 예약 내역 조회 (전체 불러오기 or 사용자 필터링 가능)
  Future<List<Reservation>> getUserReservations({String? userName}) async {
    Query query = _collection;
    if (userName != null) {
      query = query.where('userName', isEqualTo: userName);
    }
    final snapshot = await query.orderBy('date', descending: false).get();
    return snapshot.docs
        .map((doc) => Reservation.fromDoc(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// 예약 ID 기준으로 단순 삭제
  Future<void> deleteReservation(String reservationId) async {
    await _collection.doc(reservationId).delete();
  }

  /// 예약 취소 + 이메일 전송
  Future<void> deleteReservationWithEmail({
    required String reservationId,
    required String lawyerEmail,
    required String lawyerName,
    required String userName,
    required String date,
    required String time,
    required String type,
  }) async {
    await deleteReservation(reservationId); // 기존 삭제
    // ✅ 이메일 전송 (취소 알림 전용 API 만들면 좋음)
    await sendReservationEmail(
      lawyerEmail: lawyerEmail,
      lawyerName: lawyerName,
      userName: userName,
      date: date,
      time: time,
      type: type,
      isCanceled: true, // ✅ 취소
    );
  }

  /// 예약 메일 발송
  Future<void> sendReservationEmail({
    required String lawyerEmail,
    required String lawyerName,
    required String userName,
    required String date,
    required String time,
    required String type,
    bool isCanceled = false, // ✅ 기본값 false
  }) async {
    final url = '${dotenv.env['FASTAPI_BASE_URL']}/send-reservation-email';
    print('📨 이메일 전송 URL: $url');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'lawyerEmail': lawyerEmail,
        'lawyerName': lawyerName,
        'userName': userName,
        'date': date,
        'time': time,
        'type': type,
        'isCanceled': isCanceled, // ✅ FastAPI에 전달
      }),
    );
    print('📨 FastAPI 응답 코드: ${response.statusCode}');
    print('📨 FastAPI 응답 내용: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('이메일 전송 실패: ${response.body}');
    }
  }
}