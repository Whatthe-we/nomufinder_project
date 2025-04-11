import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/input_viewmodel.dart';
import '../../widgets/question_template.dart';

class InputPurposeScreen extends ConsumerWidget {
  const InputPurposeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(inputViewModelProvider.notifier);
    final state = ref.watch(inputViewModelProvider);

    return QuestionTemplate(
      currentIndex: 5,
      totalSteps: InputStep.values.length,
      question: '지금 이 앱을 이용하시려는 가장\n주된 이유나 기대는 무엇인가요?',
      options: const [
        '현재 겪고 있는 노무 문제 해결',
        '평소 궁금했던 노무 상식이나 정보 얻기',
        '혹시 모를 상황에 대비하기 위해',
        '전문가(노무사)를 찾거나 연결되기 위해',
        '기타 ( )',
      ],
      selectedOption: state.purpose,
      onSelect: vm.setPurpose,
      onBack: vm.prevStep,
      onNext: vm.nextStep,
    );
  }
}