import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String lawyerId;
  final String lawyerName;
  final String lawyerEmail;
  final DateTime date;
  final String time;
  final String type;
  final String userName;
  final String userPhone;

  Reservation({
    required this.id,
    required this.lawyerId,
    required this.lawyerName,
    required this.lawyerEmail,
    required this.date,
    required this.time,
    required this.type,
    required this.userName,
    required this.userPhone,
  });

  factory Reservation.fromDoc(String id, Map<String, dynamic> json) {
    final rawDate = json['date'];
    DateTime parsedDate;

    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate(); // 🔹 Firestore Timestamp 처리
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now(); // 🔹 ISO 문자열 처리
    } else {
      parsedDate = DateTime.now(); // 🔹 fallback
    }

    return Reservation(
      id: id,
      lawyerId: json['lawyerId'] ?? '',
      lawyerName: json['lawyerName'] ?? '',
      lawyerEmail: json['lawyerEmail'] ?? '',
      date: parsedDate,
      time: json['time'] ?? '',
      type: json['type'] ?? '',
      userName: json['userName'] ?? '',
      userPhone: json['userPhone'] ?? '',
    );
  }
}
