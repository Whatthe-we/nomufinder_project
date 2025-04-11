import 'package:flutter/material.dart';

/// 둥근 인디케이터 바
class IndicatorBar extends StatelessWidget {
  final int currentIndex;
  final int totalSteps; // 전체 스텝 수를 추가로 받음

  const IndicatorBar({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(totalSteps, (index) {
            final isActive = index == currentIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: isActive ? 30 : 12,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF0010BA) : const Color(0xFF2A2740),
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// 뒤로가기 버튼 + 인디케이터 바 함께 구성된 위젯
class IndicatorBarWithBack extends StatelessWidget {
  final int currentIndex;
  final int totalSteps; // 전체 개수 추가
  final VoidCallback onBack;

  const IndicatorBarWithBack({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 뒤로가기 버튼
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 10),
          child: Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: Colors.black),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back, size: 24, color: Colors.black),
                ),
              ),
            ),
          ),
        ),

        // 인디케이터 바
        IndicatorBar(
          currentIndex: currentIndex,
          totalSteps: totalSteps,
        ),
      ],
    );
  }
}