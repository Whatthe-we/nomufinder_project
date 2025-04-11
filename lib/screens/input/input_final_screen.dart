import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';  // 추가: GoRouter를 사용하기 위한 import
import '../../widgets/indicator_bar.dart';
import 'package:project_nomufinder/viewmodels/input_viewmodel.dart';

class InputFinalScreen extends ConsumerWidget {
  const InputFinalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(inputViewModelProvider.notifier);
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

            // 내용 영역
            Column(
              children: [
                // 인디케이터 + 뒤로가기 버튼
                IndicatorBarWithBack(
                  currentIndex: 8,
                  totalSteps: InputStep.values.length,
                  onBack: () => vm.prevStep(),
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 30, top: 20, right: 30),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '노무 고민,\n더 이상 혼자 하지 마세요.\n저희가 함께 해결해 드릴게요!',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w600,
                        height: 1.46,
                        letterSpacing: -0.28,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      // 시작하기 버튼을 누르면 home_screen.dart로 이동
                      context.go('/home');
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
                    '서비스 품질 향상을 위해, 입력하신 정보는\n개인정보를 제외한 익명 통계로 활용될 수 있습니다.',
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