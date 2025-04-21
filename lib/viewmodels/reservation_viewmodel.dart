import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation.dart';

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

  /// 예약 취소 (예약 ID 기준)
  Future<void> deleteReservation(String reservationId) async {
    await _collection.doc(reservationId).delete();
  }
}