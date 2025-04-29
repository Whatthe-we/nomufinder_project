import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_nomufinder/models/review.dart';

// ⭐️ 작성한 후기를 저장하는 전역 리스트 (추후 ViewModel로 관리 가능)
final List<Review> myReviews = [];

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 후기'),
        backgroundColor: Colors.blueAccent,
      ),
      body: myReviews.isEmpty
          ? const Center(
        child: Text(
          '아직 작성한 후기가 없습니다.\n첫 후기를 남겨보세요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: myReviews.length,
        itemBuilder: (context, index) {
          final review = myReviews[index];
          final formattedDate = DateFormat('yyyy년 M월 d일').format(review.date);

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⭐️ 별점 + 날짜
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          review.rating,
                              (index) => const Icon(Icons.star, color: Colors.amber, size: 18),
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 💬 후기 내용
                  Text(
                    review.comment,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
