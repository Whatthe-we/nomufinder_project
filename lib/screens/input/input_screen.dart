import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/input_viewmodel.dart';
import '../../widgets/indicator_bar.dart';
import 'input_gender_screen.dart';
import 'input_age_screen.dart';
import 'input_employment_screen.dart';
import 'input_industry_screen.dart';
import 'input_companysize_screen.dart';
import 'input_purpose_screen.dart';
import 'input_issue_screen.dart';
import 'input_infoneed_screen.dart';
import 'input_final_screen.dart';

class InputScreen extends ConsumerWidget {
  const InputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(inputViewModelProvider.select((s) => s.step));
    switch (step) {
      case InputStep.gender:
        return const InputGenderScreen();
      case InputStep.age:
        return const InputAgeScreen();
      case InputStep.employment:
        return const InputEmploymentScreen();
      case InputStep.industry:
        return const InputIndustryScreen();
      case InputStep.companySize:
        return const InputCompanySizeScreen();
      case InputStep.purpose:
        return const InputPurposeScreen();
      case InputStep.issue:
        return const InputIssueScreen();
      case InputStep.infoNeed:
        return const InputInfoNeedScreen();
      case InputStep.complete:
        return const InputFinalScreen();
    }
  }
}