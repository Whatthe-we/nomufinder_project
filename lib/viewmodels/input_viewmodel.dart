import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ Step 1. InputStep enum 확장 (viewmodels/input_viewmodel.dart)
enum InputStep {
  gender,
  age,
  employment,
  industry,
  companySize,
  purpose,
  issue,
  infoNeed,
  complete,
}

// ✅ Step 2. InputState 클래스 확장 (viewmodels/input_viewmodel.dart)
class InputState {
  final InputStep step;
  final String gender;
  final String age;
  final String employment;
  final String industry;
  final String companySize;
  final String purpose;
  final List<String> selectedIssues;
  final List<String> infoNeeds;

  InputState({
    this.step = InputStep.gender,
    this.gender = '',
    this.age = '',
    this.employment = '',
    this.industry = '',
    this.companySize = '',
    this.purpose = '',
    this.selectedIssues = const [],
    this.infoNeeds = const [],
  });

  InputState copyWith({
    InputStep? step,
    String? gender,
    String? age,
    String? employment,
    String? industry,
    String? companySize,
    String? purpose,
    List<String>? selectedIssues,
    List<String>? infoNeeds,
  }) {
    return InputState(
      step: step ?? this.step,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      employment: employment ?? this.employment,
      industry: industry ?? this.industry,
      companySize: companySize ?? this.companySize,
      purpose: purpose ?? this.purpose,
      selectedIssues: selectedIssues ?? this.selectedIssues,
      infoNeeds: infoNeeds ?? this.infoNeeds,
    );
  }
}

// ✅ Step 3. InputViewModel 확장 (viewmodels/input_viewmodel.dart)
class InputViewModel extends StateNotifier<InputState> {
  InputViewModel() : super(InputState());

  void nextStep() {
    final steps = InputStep.values;
    final currentIndex = steps.indexOf(state.step);
    if (currentIndex < steps.length - 1) {
      state = state.copyWith(step: steps[currentIndex + 1]);
    }
  }

  void prevStep() {
    final steps = InputStep.values;
    final currentIndex = steps.indexOf(state.step);
    if (currentIndex > 0) {
      state = state.copyWith(step: steps[currentIndex - 1]);
    }
  }

  void setGender(String value) {
    state = state.copyWith(gender: value);
  }

  void setAge(String value) {
    state = state.copyWith(age: value);
  }

  void setEmployment(String value) {
    state = state.copyWith(employment: value);
  }

  void setIndustry(String value) {
    state = state.copyWith(industry: value);
  }

  void setCompanySize(String value) {
    state = state.copyWith(companySize: value);
  }

  void setPurpose(String value) {
    state = state.copyWith(purpose: value);
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

  void toggleInfoNeed(String info) {
    final current = [...state.infoNeeds];
    if (current.contains(info)) {
      current.remove(info);
    } else {
      current.add(info);
    }
    state = state.copyWith(infoNeeds: current);
  }
}

final inputViewModelProvider =
StateNotifierProvider<InputViewModel, InputState>((ref) {
  return InputViewModel();
});