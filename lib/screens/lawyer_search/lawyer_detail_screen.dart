import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/models/review.dart';
import 'package:project_nomufinder/screens/reservation/reservation_screen.dart';

class LawyerDetailScreen extends StatefulWidget {
  final Lawyer lawyer;

  const LawyerDetailScreen({super.key, required this.lawyer});

  @override
  State<LawyerDetailScreen> createState() => _LawyerDetailScreenState();
}

class _LawyerDetailScreenState extends State<LawyerDetailScreen> {
  bool _isLatestFirst = true; // ⭐️ 최신순/오래된순 스위치

  // ✅ 임시 후기 데이터
  final List<Review> reviews = [
    Review(
      user: '김철수',
      rating: 5,
      comment: '친절하고 자세하게 상담해주셨어요.',
      date: DateTime(2025, 4, 10),
    ),
    Review(
      user: '이영희',
      rating: 4,
      comment: '빠르게 문제 해결됐습니다. 감사합니다!',
      date: DateTime(2025, 4, 15),
    ),
    Review(
      user: '박민수',
      rating: 5,
      comment: '믿고 맡길 수 있는 노무사님입니다.',
      date: DateTime(2025, 4, 20),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: Image.network(
                    widget.lawyer.profileImage,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '노무사 경력 10년',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '노무법인 아이펠 대표',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  right: 16,
                  bottom: 40,
                  child: Column(
                    children: [
                      Icon(Icons.favorite_border, color: Colors.white),
                      SizedBox(height: 12),
                      Icon(Icons.share, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
            const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: '노무사홈'),
                Tab(text: '노무사정보'),
                Tab(text: '사례'),
                Tab(text: '후기'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildHomeTab(context),
                  const Center(child: Text('노무사 정보')),
                  const Center(child: Text('사례')),
                  _buildReviewTab(), // ✅ 후기 탭
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReservationScreen(lawyer: widget.lawyer),
                  ),
                );
              },
              child: const Text('상담 예약'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.lawyer.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                widget.lawyer.address,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("분야", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...widget.lawyer.specialties.map(
                (s) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    s,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  // ✅ 후기 탭
  Widget _buildReviewTab() {
    final sortedReviews = List<Review>.from(reviews)
      ..sort((a, b) =>
      _isLatestFirst
          ? b.date.compareTo(a.date)
          : a.date.compareTo(b.date));

    if (sortedReviews.isEmpty) {
      // ⭐️ 후기 리스트가 비어있으면 안내 문구 표시
      return const Center(
        child: Text(
          '작성된 후기가 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isLatestFirst = !_isLatestFirst;
                });
              },
              child: Text(_isLatestFirst ? '최신순' : '오래된순'),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedReviews.length,
            itemBuilder: (context, index) {
              final review = sortedReviews[index];
              final formattedDate = DateFormat('yyyy년 M월 d일').format(
                  review.date);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          review.rating,
                              (index) =>
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(review.comment),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '- ${review.user}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
