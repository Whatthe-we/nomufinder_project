import 'package:cloud_firestore/cloud_firestore.dart';
import 'lawyer.dart';

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
  final DateTime createdAt;
  bool isReviewed;

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
    DateTime? createdAt,
    this.isReviewed = false,
  }) : createdAt = createdAt ?? DateTime.now();

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

    final rawCreatedAt = json['createdAt'];
    DateTime parsedCreatedAt;

    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
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
      createdAt: parsedCreatedAt,
      isReviewed: json['isReviewed'] ?? false,
    );
  }
}

extension ReservationExtension on Reservation {
  Lawyer toLawyer() {
    return Lawyer(
      id: lawyerId,
      licenseNumber: 0, // 없으니까 기본값
      name: lawyerName,
      description: '',
      specialties: [],
      phoneFee: 0,
      videoFee: 0,
      visitFee: 0,
      profileImage: '',
      address: '',
      gender: '',
      email: lawyerEmail,
      phone: '',
      badges: [],
      comment: '',
      reviews: [],
    );
  }
}
