import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:project_nomufinder/models/reservation.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // 🔔 하루 전 알림 스케줄링 (중복 제거)
  Future<void> scheduleReservationReminder(Reservation reservation) async {
    final now = DateTime.now();
    final reservationDate = reservation.date.subtract(const Duration(days: 1));

    if (reservationDate.isAfter(now)) {
      print('📅 예약 알림 스케줄링: ${reservation.lawyerName} - ${reservation.date}');

      try {
        // ✅ 바로 알림 (테스트용)
        await _messaging.subscribeToTopic(reservation.id);
        await _messaging.sendMessage(
          to: '/topics/${reservation.id}',
          data: {
            'title': '예약 알림',
            'body': '${reservation.lawyerName} 노무사와의 상담 예약이 하루 남았습니다.',
          },
        );
        print('🚀 예약 알림을 위한 토픽 구독 및 메시지 전송 완료: ${reservation.id}');
      } catch (e) {
        print('❌ 토픽 구독 실패: $e');
      }
    }
  }

  // 🔄 Firestore에서 예약 가져오기
  Future<List<Reservation>> getUpcomingReservations() async {
    final snapshot = await _firestore.collection('reservations').get();
    return snapshot.docs
        .map((doc) => Reservation.fromDoc(doc.id, doc.data()))
        .toList();
  }

  // 🔄 예약 저장
  Future<void> saveReservation(Reservation reservation) async {
    await _firestore.collection('reservations').doc(reservation.id).set({
      'lawyerId': reservation.lawyerId,
      'lawyerName': reservation.lawyerName,
      'lawyerEmail': reservation.lawyerEmail,
      'date': reservation.date.toIso8601String(),
      'time': reservation.time,
      'type': reservation.type,
      'userName': reservation.userName,
      'userPhone': reservation.userPhone,
      'createdAt': reservation.date.toIso8601String(),
      'isReviewed': reservation.isReviewed,
    });

    // 🔔 예약 알림 스케줄링
    await scheduleReservationReminder(reservation);
  }

  // ✅ 예약된 날짜와 시간을 가져오는 메서드 추가
  Future<Map<String, List<String>>> getReservedDateTimes(String lawyerId) async {
    final snapshot = await _firestore
        .collection('reservations')
        .where('lawyerId', isEqualTo: lawyerId)
        .get();

    Map<String, List<String>> reservedDateTimes = {};
    for (var doc in snapshot.docs) {
      final reservation = Reservation.fromDoc(doc.id, doc.data());
      final dateKey = reservation.date.toIso8601String().substring(0, 10);

      if (!reservedDateTimes.containsKey(dateKey)) {
        reservedDateTimes[dateKey] = [];
      }

      reservedDateTimes[dateKey]!.add(reservation.time);
    }

    return reservedDateTimes;
  }
}