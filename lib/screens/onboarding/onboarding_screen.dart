import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/indicator_bar.dart';
import '../../viewmodels/input_viewmodel.dart';
import '../../services/firebase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerWidget { // ✅ 변경
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 인디케이터 (뒤로가기 없음)
            UnifiedIndicatorBar(
              currentIndex: 9,
              totalSteps: InputStep.values.length,
              onBack: null,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30, top: 25, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '필요한 정보를 더 잘 제공하기 위해,\n간단한 질문 몇 가지를 드릴게요!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 23,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.28,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  // ❌ 바로 홈 이동 버튼
                  GestureDetector(
                    onTap: () async {
                      await FirebaseService.updateIsFirstLoginAndSurveyCompleted();
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (context.mounted) context.go('/home');
                    },
                    child: Container(
                      width: 324,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(38),
                      ),
                      child: const Center(
                        child: Text(
                          "I DON'T UNDERSTAND",
                          style: TextStyle(
                            color: Color(0xFF6B6B6B),
                            fontSize: 16,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ✅ 설문 시작 버튼
                  GestureDetector(
                    onTap: () async {
                      ref.read(inputViewModelProvider.notifier).reset(); // ← 핵심
                      await FirebaseService.updateIsFirstLoginFalse();
                      if (context.mounted) context.go('/input');
                    },
                    child: Container(
                      width: 324,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0010BA),
                        borderRadius: BorderRadius.circular(38),
                      ),
                      child: const Center(
                        child: Text(
                          '다음',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}