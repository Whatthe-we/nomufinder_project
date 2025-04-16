import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_nomufinder/models/lawyer.dart'; // ✅ Lawyer import

class ReservationSuccessScreen extends StatelessWidget {
  final DateTime date;
  final String time;
  final Lawyer lawyer; // ✅ Lawyer 객체 받기

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
      appBar: AppBar(title: const Text("예약 완료")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$formattedDate\n오후 $time\n${lawyer.name} 노무사',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            const Text(
              "예약되었습니다.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
          ],
        ),
      ),
    );
  }
}