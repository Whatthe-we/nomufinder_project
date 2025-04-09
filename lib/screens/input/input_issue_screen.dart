import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/indicator_bar.dart';
import 'package:project_nomufinder/viewmodels/input_viewmodel.dart';

class InputIssueScreen extends ConsumerWidget {
  const InputIssueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(inputViewModelProvider.notifier);
    final state = ref.watch(inputViewModelProvider);
    final selectedIssues = state.selectedIssues;
    final issues = [
      '임금 체불 (급여, 주휴수당, 퇴직금 등)',
      '부당 해고 또는 권고사직 압박',
      '근로계약서 미작성 또는 불리한 내용',
      '초과 근무 및 수당 미지급',
      '직장 내 괴롭힘 또는 성희롱',
      '연차/휴가 사용의 어려움',
      '산업재해(산재) 관련 문제',
      '고용 차별 (성별, 나이 등)',
      '기타 ( )',
      '해당 없음',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 인디케이터
            IndicatorBarWithBack(
              currentIndex: 2,
              onBack: () => vm.prevStep(),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 30, top: 20, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '현재 직장/아르바이트와 관련하여\n어떤 어려움을 경험하고 계시나요? (중복 선택 가능)',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                itemCount: issues.length,
                itemBuilder: (context, index) {
                  final issue = issues[index];
                  final selected = selectedIssues.contains(issue);
                  return GestureDetector(
                    onTap: () => vm.toggleIssue(issue),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0x194148E8) : Colors.transparent,
                        border: Border.all(
                          color: selected ? const Color(0xFF0010BA) : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              issue,
                              style: TextStyle(
                                color: selected ? Colors.black : const Color(0xFF5A5A5A),
                                fontSize: 20,
                                fontFamily: 'Work Sans',
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                                letterSpacing: -0.28,
                              ),
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check_circle, color: Color(0xFF0010BA)),
                        ],
                      ),
                    ),
                  );
                },
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
                child: const Text('모두 골랐어요'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}