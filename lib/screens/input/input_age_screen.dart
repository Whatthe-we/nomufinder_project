import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/input_viewmodel.dart';
import '../../widgets/question_template.dart';

class InputAgeScreen extends ConsumerWidget {
  const InputAgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(inputViewModelProvider.notifier);
    final state = ref.watch(inputViewModelProvider);

    return QuestionTemplate(
      currentIndex: 1, // 인디케이터 위치
      totalSteps: InputStep.values.length,
      question: '귀하의 연령대는 어떻게 되십니까?',
      options: const [
        '10대',
        '20대',
        '30대',
        '40대',
        '50대',
        '60대 이상',
      ],
      selectedOption: state.age,
      onSelect: vm.setAge,
      onBack: vm.prevStep,
      onNext: vm.nextStep,
    );
  }
}