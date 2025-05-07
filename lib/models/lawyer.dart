import '../viewmodels/search_viewmodel.dart';
import 'review.dart';

class Lawyer {
  final int licenseNumber; // licenseNumber
  final String id;
  final String name;
  final String description;
  final List<String> specialties;
  final int phoneFee;
  final int videoFee;
  final int visitFee;
  final String profileImage;
  final String address; // 주소
  final String gender;  // 성별
  final String email;   // 이메일
  final String phone;   // 연락처
  final List<String> badges;
  final String comment;
  final List<Review> reviews; // 👈 int에서 List<Review>로 변경

  Lawyer({
    required this.id, // 이제 fromJson에서 값을 할당받도록 수정
    required this.licenseNumber, // licenseNumber
    required this.name,
    required this.description,
    required List<String> specialties, // 변경 지점
    required this.phoneFee,
    required this.videoFee,
    required this.visitFee,
    required this.profileImage,
    required this.address,
    required this.gender,
    required this.email,
    required this.phone,
    required this.badges,
    required this.comment,
    required this.reviews,
  }) : specialties = List.from(specialties); // ← 이렇게 초기화하면 가변 리스트 됨

  // JSON → 객체로 역직렬화
  factory Lawyer.fromJson(Map<String, dynamic> json) {
    Map<String, int> feeMap = {};
    for (int i = 0; i < (json['consult']?.length ?? 0); i++) {
      final type = json['consult'][i];
      final priceStr = json['price'][i]
          .replaceAll(',', '')
          .replaceAll('원', '')
          .replaceAll(' ', '');
      feeMap[type] = int.tryParse(priceStr) ?? 0;
    }

    // ✅ 리뷰 데이터 처리를 수정
    List<Review> reviewsList = [];
    if (json['reviews'] is List) {
      reviewsList = (json['reviews'] as List)
          .map((reviewJson) => Review.fromJson(reviewJson))
          .toList();
    }

    return Lawyer(
      id: json['lawyer_id'] ?? '',
      licenseNumber: json['license_number'] ?? 0,
      name: json['name'] ?? '',
      description: json['desc'] ?? '',
      specialties: (json['specialty'] as List<dynamic>?)?.cast<String>().toList() ?? [],
      phoneFee: feeMap['전화상담'] ?? 0,
      videoFee: feeMap['영상상담'] ?? 0,
      visitFee: feeMap['방문상담'] ?? 0,
      profileImage: json['photo'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      badges: (json['badges'] as List<dynamic>?)?.cast<String>().toList() ?? [],
      comment: json['comment'] ?? '',
      reviews: reviewsList, // ✅ 수정된 리뷰 리스트 사용
    );
  }

  // 객체 → JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'lawyer_id': id,
      'license_number': licenseNumber,
      'name': name,
      'desc': description,
      'specialty': specialties,
      'consult': ['전화상담', '영상상담', '방문상담'],
      'price': [
        phoneFee.toString(),
        videoFee.toString(),
        visitFee.toString(),
      ],
      'photo': profileImage,
      'address': address,
      'gender': gender,
      'email': email,
      'phone': phone,
      'badges': badges,
      'comment': comment,
      'reviews': reviews.map((review) => review.toJson()).toList(), // 리뷰 리스트를 JSON 형태로 변환
    };
  }
}