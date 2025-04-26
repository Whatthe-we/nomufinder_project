import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/indicator_bar.dart'; // ✅ UnifiedIndicatorBar 포함
import 'package:project_nomufinder/viewmodels/input_viewmodel.dart';
import 'package:project_nomufinder/services/firebase_service.dart';

class InputFinalScreen extends ConsumerWidget {
  const InputFinalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(inputViewModelProvider.notifier);
    final state = ref.watch(inputViewModelProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 배경 데코 원 (좌하단)
            Positioned(
              left: -screenWidth * 0.42,
              top: screenHeight * 0.48,
              child: Container(
                width: screenWidth * 0.8,
                height: screenWidth * 0.8,
                decoration: const BoxDecoration(
                  color: Color(0x230010BA),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // 배경 데코 원 (우상단)
            Positioned(
              right: -screenWidth * 0.2,
              top: screenHeight * 0.15,
              child: Container(
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
                decoration: const BoxDecoration(
                  color: Color(0x21131313),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ✅ 인디케이터 위치 고정
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: UnifiedIndicatorBar(
                currentIndex: 8,
                totalSteps: InputStep.values.length,
                onBack: vm.prevStep,
              ),
            ),

            // ✅ 본문 내용
            Column(
              children: [
                const SizedBox(height: 110), // 인디케이터 높이 공간 확보

                const Padding(
                  padding: EdgeInsets.only(left: 30, top: 4, right: 30),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '노무 고민,\n더 이상 혼자 하지 마세요.\n저희가 함께 해결해 드릴게요!',
                      style: TextStyle(
                        fontSize: 23,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w700,
                        height: 1.46,
                        letterSpacing: -0.28,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // 시작하기 버튼
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () async {
                      final inputState = ref.read(inputViewModelProvider);

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      try {
                        await FirebaseService.saveSurvey(inputState);

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          context.go('/home');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('저장 실패: $e')),
                          );
                        }
                      }
                    },
                    child: Container(
                      height: 64,
                      width: 324,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0010BA),
                        borderRadius: BorderRadius.circular(38),
                      ),
                      child: const Center(
                        child: Text(
                          '시작하기',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text(
                    '서비스 품질 향상을 위해,\n입력하신 정보는 익명 통계로 활용될 수 있습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9B9B9B),
                      fontSize: 12,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
