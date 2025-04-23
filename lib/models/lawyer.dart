import '../viewmodels/search_viewmodel.dart';

class Lawyer {
  final int licenseNumber; // licenseNumber
  final String name;
  final String description;
  final List<String> specialties;
  final int phoneFee;
  final int videoFee;
  final int visitFee;
  final String profileImage;
  final String address; // 주소
  final String gender; // 성별
  final String email; // 이메일
  final String phone; // 연락처
  final List<String> badges;
  final String comment;
  final int reviews;

  Lawyer({
    required this.licenseNumber, // licenseNumber
    required this.name,
    required this.description,
    required List<String> specialties, // 변경 지점
    required this.phoneFee,
    required this.videoFee,
    required this.visitFee,
    required this.profileImage,
    required this.address,
    required this.gender,      // 성별
    required this.email,       // 이메일
    required this.phone,       // 연락처
  }) : specialties = List.from(specialties); // ← 이렇게 초기화하면 가변 리스트 됨

  // ✅ JSON → 객체로 역직렬화
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

    return Lawyer(
      licenseNumber: json['license_number'] ?? 0,
      name: json['name'] ?? '',
      description: json['desc'] ?? '',
      specialties: (json['specialty'] as List<dynamic>)
          .expand((e) => e is List ? e : [e])
          .cast<String>()
          .toList(),
      phoneFee: feeMap['전화상담'] ?? 0,
      videoFee: feeMap['영상상담'] ?? 0,
      visitFee: feeMap['방문상담'] ?? 0,
      profileImage: json['photo'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      badges: List<String>.from(json['badges']),
      comment: json['comment'],
      reviews: json['reviews'],
    );
  }

  // ✅ 객체 → JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
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
    };
  }
}