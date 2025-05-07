import '../viewmodels/search_viewmodel.dart';
import 'review.dart';

class Lawyer {
  final int licenseNumber;
  final String id;
  final String name;
  final String description;
  final List<String> specialties;
  final int phoneFee;
  final int videoFee;
  final int visitFee;
  final String profileImage;
  final String address;
  final String gender;
  final String email;
  final String phone;
  final List<String> badges;
  final String comment;
  final List<Review> reviews;

  Lawyer({
    required this.id,
    required this.licenseNumber,
    required this.name,
    required this.description,
    required this.specialties,
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
  });

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
      id: json['lawyer_id'] ?? '',
      licenseNumber: json['license_number'] ?? 0,
      name: json['name'] ?? '',
      description: json['desc'] ?? '',
      specialties: (json['specialties'] as List?)?.cast<String>() ?? [], // 🔄 수정된 부분
      phoneFee: feeMap['전화상담'] ?? 0,
      videoFee: feeMap['영상상담'] ?? 0,
      visitFee: feeMap['방문상담'] ?? 0,
      profileImage: json['photo'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      badges: (json['badges'] as List?)?.cast<String>() ?? [],
      comment: json['comment'] ?? '',
      reviews: [], // 임시 초기화
    );
  }

  // ✅ Map → 객체로 역직렬화 (Firestore에서 불러올 때)
  factory Lawyer.fromMap(String id, Map<String, dynamic> map) {
    Map<String, int> feeMap = {};
    final consult = (map['consult'] as List?) ?? [];
    final price = (map['price'] as List?) ?? [];

    for (int i = 0; i < consult.length; i++) {
      final type = consult[i];
      final priceStr = price[i].toString().replaceAll(RegExp(r'[^0-9]'), '');
      feeMap[type] = int.tryParse(priceStr) ?? 0;
    }
    return Lawyer(
      id: id,
      licenseNumber: map['license_number'] ?? 0,
      name: map['name'] ?? '',
      description: map['desc'] ?? '',
      specialties: (map['specialties'] as List?)?.cast<String>() ?? [], // 🔄 수정된 부분
      phoneFee: feeMap['전화상담'] ?? 0,
      videoFee: feeMap['영상상담'] ?? 0,
      visitFee: feeMap['방문상담'] ?? 0,
      profileImage: map['photo'] ?? '',
      address: map['address'] ?? '',
      gender: map['gender'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      badges: (map['badges'] as List?)?.cast<String>() ?? [],
      comment: map['comment'] ?? '',
      reviews: [],
    );
  }

  // ✅ 객체 → JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'lawyer_id': id,
      'license_number': licenseNumber,
      'name': name,
      'desc': description,
      'specialties': specialties, // 🔄 수정된 부분
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
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }
}
