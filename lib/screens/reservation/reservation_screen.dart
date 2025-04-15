import 'package:flutter/material.dart';
import 'package:project_nomufinder/models/lawyer.dart';

class ReservationScreen extends StatelessWidget {
  final Lawyer lawyer;

  const ReservationScreen({super.key, required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약하기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${lawyer.name} 노무사님과의 상담을 예약합니다.',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('날짜 선택'),
            const SizedBox(height: 10),
            Container(
              height: 50,
              color: Colors.grey[200],
              child: const Center(child: Text('📅 날짜 선택 기능 (캘린더 연동 예정)')),
            ),
            const SizedBox(height: 20),
            const Text('시간 선택'),
            const SizedBox(height: 10),
            Container(
              height: 50,
              color: Colors.grey[200],
              child: const Center(child: Text('⏰ 시간 선택 기능')),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 다음 단계 구현
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0010BA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('다음', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
