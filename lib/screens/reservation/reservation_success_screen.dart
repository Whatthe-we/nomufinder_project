import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:go_router/go_router.dart'; // ✅ GoRouter import

class ReservationSuccessScreen extends StatelessWidget {
  final DateTime date;
  final String time;
  final Lawyer lawyer;

  const ReservationSuccessScreen({
    super.key,
    required this.date,
    required this.time,
    required this.lawyer,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy년 M월 d일').format(date);

    return Scaffold(
      appBar: AppBar(
        title: const Text("예약 완료", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0010B9),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ 예약 정보 카드
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 80),
                    const SizedBox(height: 20),
                    Text(
                      "예약이 완료되었습니다!",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0010B9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$formattedDate\n$time\n${lawyer.name} 노무사',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ✅ 홈으로 돌아가기 버튼
            ElevatedButton.icon(
              onPressed: () {
                // ✅ 홈으로 이동 (스택 제거)
                context.go('/home'); // ✅ 홈으로 이동
              },
              icon: const Icon(Icons.home, color: Colors.white),
              label: const Text(
                "홈으로 돌아가기",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0010B9),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}