import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/input_viewmodel.dart';
import '../../widgets/question_template.dart';

class InputEmploymentScreen extends ConsumerWidget {
  const InputEmploymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(inputViewModelProvider.notifier);
    final state = ref.watch(inputViewModelProvider);

    return QuestionTemplate(
      currentIndex: 2,
      totalSteps: InputStep.values.length,
      question: '귀하의 고용 형태는 어떻게 되나요?',
      options: const [
        '정규직',
        '계약직/파견직',
        '아르바이트/단기근로',
        '자영업/프리랜서',
        '구직중',
        '은퇴',
        '기타',
      ],
      selectedOption: state.employment,
      onSelect: vm.setEmployment,
      onBack: vm.prevStep,
      onNext: vm.nextStep,
    );
  }
}