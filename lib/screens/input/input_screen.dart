import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/input_viewmodel.dart';
import '../../widgets/indicator_bar.dart';
import 'input_gender_screen.dart';
import 'input_issue_screen.dart';
import 'input_final_screen.dart';

class InputScreen extends ConsumerWidget {
  const InputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(inputViewModelProvider.select((s) => s.step));
    switch (step) {
      case InputStep.gender:
        return const InputGenderScreen();
      case InputStep.issue:
        return const InputIssueScreen();
      case InputStep.complete:
        return const InputFinalScreen();
    }
  }
}