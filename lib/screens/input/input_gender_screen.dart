import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/indicator_bar.dart';
import 'package:project_nomufinder/viewmodels/input_viewmodel.dart';

class InputGenderScreen extends ConsumerWidget {
  const InputGenderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(inputViewModelProvider.notifier);
    final state = ref.watch(inputViewModelProvider);
    final gender = state.gender;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            IndicatorBarWithBack(
              currentIndex: 1,
              onBack: () => vm.prevStep(),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 30, top: 20, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '당신의 성별을 선택해주세요!',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: ['여성', '남성', '제 3의 성'].map(
                        (option) => GestureDetector(
                      onTap: () => vm.setGender(option),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: gender == option ? const Color(0xFF0010BA) : Colors.transparent,
                            width: 2,
                          ),
                          color: gender == option ? const Color(0x194148E8) : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                color: gender == option ? Colors.black : const Color(0xFF5A5A5A),
                                fontSize: 24,
                                fontFamily: 'Work Sans',
                                fontWeight: gender == option ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (gender == option)
                              const Icon(Icons.check_circle, color: Color(0xFF0010BA)),
                          ],
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ElevatedButton(
                onPressed: () => vm.nextStep(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0010BA),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(324, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(38),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20, // 기존보다 키움
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Open Sans',
                    letterSpacing: 2,
                  ),
                ),
                child: const Text('다음'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}