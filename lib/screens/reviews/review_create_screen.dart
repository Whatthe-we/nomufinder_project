import 'package:flutter/material.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/models/review.dart';
import 'package:project_nomufinder/screens/reviews/my_reviews_screen.dart';

class ReviewCreateScreen extends StatefulWidget {
  final Lawyer lawyer;

  const ReviewCreateScreen({super.key, required this.lawyer});

  @override
  State<ReviewCreateScreen> createState() => _ReviewCreateScreenState();
}

class _ReviewCreateScreenState extends State<ReviewCreateScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  bool _isSubmitted = false;

  void _submitReview() {
    final comment = _commentController.text.trim();

    if (comment.isEmpty || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('별점과 리뷰 내용을 입력해 주세요!')),
      );
      return;
    }

    final newReview = Review(
      user: '홍길동',
      rating: _rating,
      comment: comment,
      date: DateTime.now(),
    );

    widget.lawyer.reviews.add(newReview);
    myReviews.add(newReview);

    setState(() {
      _isSubmitted = true;
    });

    // 작성 후 바로 이전 화면으로 이동
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('후기 작성'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '노무사 상담은 어떠셨나요?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ⭐️ 별점
            Row(
              children: [
                ...List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: _isSubmitted
                        ? null
                        : () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
                Text('$_rating / 5', style: const TextStyle(fontSize: 16, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              '리뷰 내용',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _commentController,
              maxLines: 6,
              maxLength: 300,
              enabled: !_isSubmitted,
              decoration: InputDecoration(
                hintText: '상담은 어땠는지 자유롭게 적어주세요 :)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 60), // 버튼과 간격 확보
          ],
        ),
      ),

      // ✅ 하단 버튼 (위로 띄워줌)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isSubmitted ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSubmitted ? Colors.grey : Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              _isSubmitted ? '후기 작성 완료' : '후기 제출',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
