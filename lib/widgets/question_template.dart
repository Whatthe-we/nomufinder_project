import 'package:flutter/material.dart';
import 'indicator_bar.dart';

class QuestionTemplate extends StatelessWidget {
  final int currentIndex;
  final int totalSteps;
  final String question;
  final List<String> options;
  final String? selectedOption;
  final List<String>? selectedOptions;
  final void Function(String) onSelect;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool isMultiple;
  final bool showBackButton;

  const QuestionTemplate({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
    required this.question,
    required this.options,
    this.selectedOption,
    this.selectedOptions,
    required this.onSelect,
    required this.onBack,
    required this.onNext,
    this.isMultiple = false,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    // 선택 여부 확인
    bool isSelected = isMultiple
        ? (selectedOptions != null && selectedOptions!.isNotEmpty)
        : (selectedOption != null && selectedOption!.isNotEmpty);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 인디케이터 + 뒤로가기
            UnifiedIndicatorBar(
              currentIndex: currentIndex,
              totalSteps: totalSteps,
              onBack: showBackButton ? onBack : null,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 25, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 23,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.28,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final selected = isMultiple
                      ? selectedOptions?.contains(option) ?? false
                      : selectedOption == option;

                  return GestureDetector(
                    onTap: () => onSelect(option),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selected ? const Color(0xFF0010BA) : Colors.transparent,
                          width: 2,
                        ),
                        color: selected ? const Color(0x194148E8) : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Work Sans',
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                                color: selected ? Colors.black : const Color(0xFF5A5A5A),
                              ),
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check_circle, color: Color(0xFF0010BA)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 선택 안 된 경우 경고 문구
            if (!isSelected)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  '👉 항목을 선택해주세요 !',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // "다음" 버튼 (선택된 경우에만 활성화)
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ElevatedButton(
                onPressed: isSelected ? onNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0010BA),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(324, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(38),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Open Sans',
                    letterSpacing: 2,
                  ),
                ),
                child: const Text('다음'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}