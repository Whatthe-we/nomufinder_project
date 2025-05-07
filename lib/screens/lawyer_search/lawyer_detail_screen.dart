import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/models/review.dart';
import 'package:project_nomufinder/screens/reservation/reservation_screen.dart';

class LawyerDetailScreen extends StatelessWidget {
  final String lawyerId;
  const LawyerDetailScreen({super.key, required this.lawyerId});

  @override
  Widget build(BuildContext context) {
    if (lawyerId.isEmpty) {
      return const Scaffold(body: Center(child: Text("잘못된 노무사 정보입니다.")));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('lawyers').doc(lawyerId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("노무사를 찾을 수 없습니다.")));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final docId = snapshot.data!.id;
        final lawyer = Lawyer.fromMap(docId, data);

        return _LawyerDetailUI(lawyer: lawyer);
      },
    );
  }
}

class _LawyerDetailUI extends StatefulWidget {
  final Lawyer lawyer;
  const _LawyerDetailUI({super.key, required this.lawyer});

  @override
  State<_LawyerDetailUI> createState() => _LawyerDetailUIState();
}

class _LawyerDetailUIState extends State<_LawyerDetailUI> {
  bool _isLatestFirst = true;
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    reviews = [
      Review(user: '김철수', rating: 5, comment: '친절하고 자세하게 상담해주셨어요.', date: DateTime(2025, 4, 10)),
      Review(user: '이영희', rating: 4, comment: '빠르게 문제 해결됐습니다. 감사합니다!', date: DateTime(2025, 4, 15)),
      Review(user: '박민수', rating: 5, comment: '믿고 맡길 수 있는 노무사님입니다.', date: DateTime(2025, 4, 20)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.lawyer.name, overflow: TextOverflow.ellipsis, maxLines: 1),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          centerTitle: true,
        ),
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
                  _buildHomeTab(),
                  const Center(child: Text('노무사 정보')),
                  const Center(child: Text('사례')),
                  _buildReviewTab(),
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

  Widget _buildHomeTab() {
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
              Text(widget.lawyer.address, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    final sortedReviews = List<Review>.from(reviews)
      ..sort((a, b) => _isLatestFirst ? b.date.compareTo(a.date) : a.date.compareTo(b.date));

    if (sortedReviews.isEmpty) {
      return const Center(child: Text('작성된 후기가 없습니다.', style: TextStyle(fontSize: 16, color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedReviews.length,
      itemBuilder: (context, index) {
        final review = sortedReviews[index];
        final formattedDate = DateFormat('yyyy년 M월 d일').format(review.date);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(review.rating, (index) => const Icon(Icons.star, color: Colors.amber, size: 16)),
                ),
                const SizedBox(height: 6),
                Text(review.comment),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('- ${review.user}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}