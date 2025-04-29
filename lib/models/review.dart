class Review {
  final String user;
  final int rating; // 별점
  final String comment; // 리뷰 내용
  final DateTime date; // 작성 날짜

  Review({
    required this.user,
    required this.rating,
    required this.comment,
    required this.date,
  });

  // JSON → Review 객체로 변환
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      user: json['user'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(), // null이면 현재시간
    );
  }

  // Review 객체 → JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(), // 저장할 때 문자열로 변환
    };
  }
}
