class Lawyer {
  final String name;
  final String description;
  final List<String> specialties;
  final int phoneFee;
  final int videoFee;
  final int visitFee;
  final String profileImage;

  Lawyer({
    required this.name,
    required this.description,
    required this.specialties,
    required this.phoneFee,
    required this.videoFee,
    required this.visitFee,
    required this.profileImage,
  });

  factory Lawyer.fromJson(Map<String, dynamic> json) {
    // 상담유형과 가격 매칭
    Map<String, int> feeMap = {};
    for (int i = 0; i < (json['consult']?.length ?? 0); i++) {
      final type = json['consult'][i];
      final priceStr = json['price'][i].replaceAll(',', '').replaceAll('원', '');
      feeMap[type] = int.tryParse(priceStr) ?? 0;
    }

    return Lawyer(
      name: json['name'] ?? '',
      description: json['desc'] ?? '',
      specialties: List<String>.from(json['specialty'] ?? []),
      phoneFee: feeMap['전화상담'] ?? 0,
      videoFee: feeMap['영상상담'] ?? 0,
      visitFee: feeMap['방문상담'] ?? 0,
      profileImage: json['photo'] ?? '',
    );
  }
}
