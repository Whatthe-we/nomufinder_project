import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_nomufinder/models/reservation.dart';
import 'package:project_nomufinder/viewmodels/reservation_viewmodel.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  final ReservationViewModel _viewModel = ReservationViewModel();
  List<Reservation> _reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final results = await _viewModel.getUserReservations(userName: '홍길동'); // TODO: 사용자 정보 연동
    setState(() {
      _reservations = results;
    });
  }

  Future<void> _cancelReservation(Reservation r) async {
    await _viewModel.deleteReservationWithEmail(
      reservationId: r.id,
      lawyerEmail: r.lawyerEmail,
      lawyerName: r.lawyerName,
      userName: r.userName,
      date: DateFormat('yyyy-MM-dd').format(r.date),
      time: r.time,
      type: r.type,
    );
    await _loadReservations();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('예약이 취소되었습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("예약 내역")),
      body: _reservations.isEmpty
          ? const Center(child: Text("예약 내역이 없습니다."))
          : ListView.builder(
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          final r = _reservations[index];
          final date = DateFormat('yyyy년 M월 d일').format(r.date);
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text('${r.lawyerName} 노무사와의 상담'),
              subtitle: Text('$date ${r.time} (${r.type})'),
              trailing: TextButton(
                onPressed: () => _cancelReservation(r),
                child: const Text('예약 취소', style: TextStyle(color: Colors.red)),
              ),
            ),
          );
        },
      ),
    );
  }
}