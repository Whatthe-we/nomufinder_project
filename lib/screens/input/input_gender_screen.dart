import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/input_viewmodel.dart';
import '../../widgets/question_template.dart';

class InputGenderScreen extends ConsumerWidget {
  const InputGenderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(inputViewModelProvider.notifier);
    final state = ref.watch(inputViewModelProvider);

    return QuestionTemplate(
      currentIndex: 0,
      totalSteps: InputStep.values.length,
      question: '당신의 성별을 선택해주세요!',
      options: const ['여성', '남성', '제 3의 성'],
      selectedOption: state.gender,
      onSelect: vm.setGender,
      onBack: vm.prevStep,
      onNext: vm.nextStep,
      showBackButton: false, // 👈 요거 추가
    );
  }
}