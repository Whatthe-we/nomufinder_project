import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/input_viewmodel.dart';
import '../../widgets/question_template.dart';

class InputIssueScreen extends ConsumerWidget {
  const InputIssueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(inputViewModelProvider.notifier);
    final state = ref.watch(inputViewModelProvider);

    return QuestionTemplate(
      currentIndex: 6,
      totalSteps: InputStep.values.length,
      question: '현재 직장/아르바이트와 관련하여\n어떤 어려움을 경험하고 계시나요? (중복 선택 가능)',
      options: const [
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
      ],
      selectedOptions: state.selectedIssues,
      isMultiple: true,
      onSelect: vm.toggleIssue,
      onBack: vm.prevStep,
      onNext: vm.nextStep,
    );
  }
}