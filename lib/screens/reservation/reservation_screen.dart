import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart'; // 📅 캘린더 패키지
import 'package:project_nomufinder/models/lawyer.dart';

class ReservationScreen extends StatefulWidget {
  final Lawyer lawyer; // ✅ Lawyer 객체 전체 받기

  const ReservationScreen({super.key, required this.lawyer});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;
  String _selectedType = '전화';

  final List<String> consultationTypes = ['전화', '영상', '방문'];
  final List<String> timeSlots = [
    '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30',
    '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00',
  ];

  void _goToNextPage() {
    if (_selectedDay != null && _selectedTime != null) {
      context.go('/reservation_success', extra: {
        'date': _selectedDay,
        'time': _selectedTime,
        'lawyer': widget.lawyer, // ✅ Lawyer 객체 그대로 넘김
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('날짜와 시간을 선택해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.lawyer.name} 노무사 예약')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: consultationTypes.map((e) => e == _selectedType).toList(),
              onPressed: (index) {
                setState(() {
                  _selectedType = consultationTypes[index];
                });
              },
              borderRadius: BorderRadius.circular(8),
              children: consultationTypes
                  .map((type) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(type),
              ))
                  .toList(),
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
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: timeSlots.map((slot) {
                final isSelected = _selectedTime == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedTime = slot),
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToNextPage,
                child: const Text('다음'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
