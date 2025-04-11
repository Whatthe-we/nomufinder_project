import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/input_viewmodel.dart';
import '../../widgets/question_template.dart';

class InputCompanySizeScreen extends ConsumerWidget {
  const InputCompanySizeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(inputViewModelProvider.notifier);
    final state = ref.watch(inputViewModelProvider);

    return QuestionTemplate(
      currentIndex: 4,
      totalSteps: InputStep.values.length,
      question: '현재 (또는 가장 최근) 근무하시는\n사업장의 규모는 어느 정도인가요?',
      options: const [
        '5인 미만',
        '5인 이상 ~ 30인 미만',
        '30인 이상 ~ 100인 미만',
        '100인 이상',
        '잘 모름 / 해당 없음',
      ],
      selectedOption: state.companySize,
      onSelect: vm.setCompanySize,
      onBack: vm.prevStep,
      onNext: vm.nextStep,
    );
  }
}