import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart'; // 📅 캘린더 패키지
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/viewmodels/reservation_viewmodel.dart'; // 예약 저장
import 'package:flutter_dotenv/flutter_dotenv.dart';

final ReservationViewModel _reservationVM = ReservationViewModel();
Map<String, List<String>> _reservedDateTimes = {}; // 날짜별 예약된 시간들

class ReservationScreen extends StatefulWidget {
  final Lawyer lawyer; // Lawyer 객체 전체 받기

  const ReservationScreen({super.key, required this.lawyer});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;
  String _selectedType = '전화';
  List<DateTime> _disabledDates = []; // 비활성화 기능

  @override
  void initState() {
    super.initState();
    _loadReservedDateTimes(); // 날짜 + 시간 조합
  }

  void _loadReservedDateTimes() async {
    final data = await _reservationVM
        .getReservedDateTimes(widget.lawyer.licenseNumber.toString());
    setState(() {
      _reservedDateTimes = data;
    });
  }

  final List<String> consultationTypes = ['전화', '영상', '방문'];
  final List<String> timeSlots = [
    '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30',
    '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00',
  ];

  void _goToNextPage() async {
    if (_selectedDay == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('날짜와 시간을 선택해주세요.')),
      );
      return;
    }

    final selectedDate = _selectedDay!.toIso8601String().substring(0, 10);
    final isAlreadyReserved =
        _reservedDateTimes[selectedDate]?.contains(_selectedTime) ?? false;

    if (isAlreadyReserved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 예약된 시간입니다.')),
      );
      return;
    }

    try {
      // 환경변수 확인 로그 (여기에 추가!)
      print('📡 FASTAPI BASE URL (Flutter): ${dotenv.env['FASTAPI_BASE_URL']}');

      // 예약 저장
      await _reservationVM.saveReservation(
        lawyerId: widget.lawyer.licenseNumber.toString(),
        lawyerName: widget.lawyer.name,
        date: _selectedDay!,
        time: _selectedTime!,
        type: _selectedType,
        userName: '홍길동',
        userPhone: '010-0000-0000',
        lawyerEmail: widget.lawyer.email,
      );

      // 예약 완료 페이지 이동
      context.go('/reservation_success', extra: {
        'date': _selectedDay!.toIso8601String(),
        'time': _selectedTime!,
        'lawyer': widget.lawyer.toJson(), // 안전하게 전달
      });
    } catch (e) {
      print('❌ 오류 발생: $e'); // ← 실제 에러 출력
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약 저장에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.lawyer.name} 노무사 예약',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0010B9),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center( // 가운데 정렬
                      child: ToggleButtons(
                        isSelected: consultationTypes.map((e) => e == _selectedType).toList(),
                        onPressed: (index) {
                          setState(() {
                            _selectedType = consultationTypes[index];
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        selectedColor: Colors.white,
                        fillColor: const Color(0xFF0010B9),
                        children: consultationTypes.map((type) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(type),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 60)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selected, focused) {
                        setState(() {
                          _selectedDay = selected;
                          _focusedDay = focused;
                        });
                      },
                      enabledDayPredicate: (day) {
                        return !_disabledDates.any((d) => isSameDay(d, day));
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: const Color(0xFF0010B9),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.blue[200],
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),
                    const SizedBox(height: 20),

                    GridView.count(
                      crossAxisCount: 3, // 더 넓게!
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.0, // 크기 키움
                      children: timeSlots.map((slot) {
                        final isSelected = _selectedTime == slot;
                        final dateKey = _selectedDay != null
                            ? _selectedDay!.toIso8601String().substring(0, 10)
                            : '';
                        final isDisabled = _reservedDateTimes[dateKey]?.contains(slot) ?? false;

                        return ChoiceChip(
                          label: Text(slot),
                          selected: isSelected,
                          onSelected: isDisabled ? null : (_) => setState(() => _selectedTime = slot),
                          selectedColor: const Color(0xFF0010B9),
                          backgroundColor: isDisabled ? Colors.grey[400] : Colors.grey[200],
                          labelStyle: TextStyle(
                            color: isDisabled ? Colors.white : isSelected ? Colors.white : Colors.black,
                            fontSize: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0010B9),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _goToNextPage,
                  child: const Text('다음', style:
                  TextStyle(
                      fontSize: 14,
                      color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}