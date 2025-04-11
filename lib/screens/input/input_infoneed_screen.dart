import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/input_viewmodel.dart';
import '../../widgets/question_template.dart';

class InputInfoNeedScreen extends ConsumerWidget {
  const InputInfoNeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(inputViewModelProvider.notifier);
    final state = ref.watch(inputViewModelProvider);

    return QuestionTemplate(
      currentIndex: 7,
      totalSteps: InputStep.values.length,
      question: '이 앱을 통해 주로 어떤 종류의\n정보나 도움을 얻고 싶으신가요?\n(중복 선택 가능)',
      options: const [
        '내 권리가 무엇인지 확인 (급여, 휴가 등)',
        '문제 발생 시 법적 절차나 대응 방법 안내',
        '나와 비슷한 다른 사람들의 사례 검색',
        '전문가의 구체적인 조언 또는 의견',
        '분쟁 예방을 위한 사전 정보',
        '필요한 서류 양식 또는 작성 도움',
        '관련 기관(노동청 등) 정보 또는 연결',
      ],
      selectedOptions: state.infoNeeds,
      isMultiple: true,
      onSelect: vm.toggleInfoNeed,
      onBack: vm.prevStep,
      onNext: vm.nextStep,
    );
  }
}