import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/input_viewmodel.dart';
import '../../widgets/question_template.dart';

class InputIndustryScreen extends ConsumerWidget {
  const InputIndustryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(inputViewModelProvider.notifier);
    final state = ref.watch(inputViewModelProvider);

    return QuestionTemplate(
      currentIndex: 3,
      totalSteps: InputStep.values.length,
      question: '현재 (또는 가장 최근에)\n종사하고 계신 업종은 무엇인가요?',
      options: const [
        '서비스업 (음식점, 판매, 운송 등)',
        '제조업/생산직',
        '사무/관리직',
        'IT/기술직',
        '건설/노무직',
        '교육/연구직',
        '보건/의료/사회복지',
        '프리랜서/플랫폼 노동자',
        '기타 ( )',
        '해당 없음',
      ],
      selectedOption: state.industry,
      onSelect: vm.setIndustry,
      onBack: vm.prevStep,
      onNext: vm.nextStep,
    );
  }
}
