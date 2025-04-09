import 'package:flutter_riverpod/flutter_riverpod.dart';

enum InputStep {
  gender,
  issue,
  complete,
}

class InputState {
  final InputStep step;
  final String gender;
  final List<String> selectedIssues;

  InputState({
    this.step = InputStep.gender,
    this.gender = '',
    this.selectedIssues = const [],
  });

  InputState copyWith({
    InputStep? step,
    String? gender,
    List<String>? selectedIssues,
  }) {
    return InputState(
      step: step ?? this.step,
      gender: gender ?? this.gender,
      selectedIssues: selectedIssues ?? this.selectedIssues,
    );
  }
}

class InputViewModel extends StateNotifier<InputState> {
  InputViewModel() : super(InputState());

  void nextStep() {
    if (state.step == InputStep.gender) {
      state = state.copyWith(step: InputStep.issue);
    } else if (state.step == InputStep.issue) {
      state = state.copyWith(step: InputStep.complete);
    }
  }

  void prevStep() {
    if (state.step == InputStep.issue) {
      state = state.copyWith(step: InputStep.gender);
    } else if (state.step == InputStep.complete) {
      state = state.copyWith(step: InputStep.issue);
    }
  }

  void setGender(String value) {
    state = state.copyWith(gender: value);
  }

  void toggleIssue(String issue) {
    final current = [...state.selectedIssues];
    if (current.contains(issue)) {
      current.remove(issue);
    } else {
      current.add(issue);
    }
    state = state.copyWith(selectedIssues: current);
  }
}

final inputViewModelProvider =
StateNotifierProvider<InputViewModel, InputState>((ref) {
  return InputViewModel();
});