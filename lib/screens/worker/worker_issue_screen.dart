import 'package:flutter/material.dart';

class WorkerIssueScreen extends StatelessWidget {
  const WorkerIssueScreen({super.key});

  final List<String> issues = const [
    '부당해고', '부당징계',
    '근로계약', '근무조건',
    '직장 내 성희롱', '직장 내 차별',
    '임금/퇴직금', '직장 내 괴롭힘',
    '산업재해', '노동조합',
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ 오른쪽 하단에 "전체보기"를 고정시키기 위해 빈칸 추가
    final List<String> fullList = [
      ...issues,
      '',             // 왼쪽 빈칸
      '+ 전체보기',     // 오른쪽 아래 고정
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: fullList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
        ),
        itemBuilder: (context, index) {
          final issue = fullList[index];
          final isLast = issue == '+ 전체보기';
          final isEmpty = issue.isEmpty;

          return GestureDetector(
            onTap: () {
              if (isEmpty) return;
              // TODO: 상세 페이지 이동
            },
            child: Container(
              decoration: BoxDecoration(
                color: isEmpty
                    ? Colors.transparent
                    : isLast
                    ? Colors.white
                    : const Color(0xFFF2F1FA),
                borderRadius: BorderRadius.circular(12),
                border: isLast
                    ? Border.all(color: Colors.grey.shade300)
                    : null,
              ),
              child: Center(
                child: Text(
                  issue,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
