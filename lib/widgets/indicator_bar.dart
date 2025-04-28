import 'package:flutter/material.dart';

/// 둥근 인디케이터 바 + 선택적 뒤로가기 버튼
class UnifiedIndicatorBar extends StatelessWidget {
  final int currentIndex;
  final int totalSteps;
  final VoidCallback? onBack; // 뒤로가기 버튼이 없을 수도 있음

  const UnifiedIndicatorBar({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90, // 고정 높이
      child: Stack(
        children: [
          // 인디케이터 바 (항상 가운데 아래 위치)
          Align(
            alignment: const Alignment(0, 0.8),
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

          // 뒤로가기 버튼 (옵션)
          if (onBack != null)
            Positioned(
              top: 20,
              left: 20,
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
        ],
      ),
    );
  }
}
