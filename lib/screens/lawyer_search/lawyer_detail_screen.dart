import 'package:flutter/material.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/screens/reservation/reservation_screen.dart';

class LawyerDetailScreen extends StatelessWidget {
  final Lawyer lawyer;

  const LawyerDetailScreen({super.key, required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            // ✅ 상단 이미지 + 소개 텍스트 + 버튼 오버레이
            Stack(
              children: [
                SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: Image.network(
                    lawyer.profileImage,
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
                )
              ],
            ),

            // ✅ 탭바
            const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: '노무사홈'),
                Tab(text: '노무사정보'),
                Tab(text: '사례'),
                Tab(text: '후기 4'),
              ],
            ),

            // ✅ 탭 내용
            Expanded(
              child: TabBarView(
                children: [
                  _buildHomeTab(context),
                  const Center(child: Text('노무사 정보')),
                  const Center(child: Text('사례')),
                  const Center(child: Text('후기')),
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
                    builder: (_) => ReservationScreen(lawyer: lawyer),
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
            lawyer.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                lawyer.address, // ✅ 여기만 바꿨어!
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("분야", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...lawyer.specialties.map(
                (s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                height: 18,
                color: Colors.grey.shade200,
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}