import 'package:flutter/material.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/screens/lawyer_search/lawyer_list_screen.dart';
import 'package:project_nomufinder/services/lawyer_data_loader.dart';
import 'package:project_nomufinder/viewmodels/search_viewmodel.dart';

// 파일 최상단 또는 클래스 외부로 이동
final Map<String, List<String>> issueKeywordMap = {
  '직장 내 성희롱': ['성희롱', '직장내성희롱', '괴롭힘·성희롱'],
  '직장 내 괴롭힘': ['괴롭힘', '직장내괴롭힘', '괴롭힘·성희롱'],
  '근무조건': ['근무조건', '근로계약/근무조건 상담'],
  '근로계약': ['근로계약', '근로계약/근무조건 상담'],
  '임금/퇴직금': ['임금/퇴직금', '임금체불', '급여'],
  '노동조합': ['노동조합'],
  '산업재해': ['산업재해'],
  '부당해고': ['부당해고'],
  '부당징계': ['부당징계'],
  '직장 내 차별': ['차별'],
};

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
    final List<String> fullList = [
      ...issues,
      '',
      '+ 전체보기',
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

              // 전체보기일 경우 모든 노무사 가져오기
              final filtered = isLast
                  ? lawyersByRegion.values.expand((list) => list).toList()
                  : lawyersByRegion.values
                  .expand((list) => list)
                  .where((lawyer) {
                final normalized = normalizeCategory(issue);
                final keywords = issueKeywordMap[normalized] ?? [normalized];
                return lawyer.specialties.any(
                      (tag) => keywords.any((keyword) => tag.contains(keyword)),
                );
              }).toList();

              // 노무사 리스트 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LawyerListScreen(
                    title: isLast ? '전체보기' : issue,
                    category: isLast ? '' : issue,
                    lawyers: filtered,
                  ),
                ),
              );
            },

            child: Container(
              decoration: BoxDecoration(
                color: isEmpty
                    ? Colors.transparent
                    : isLast
                    ? Colors.white
                    : const Color(0xFFF2F1FA),
                borderRadius: BorderRadius.circular(12),
                border:
                isLast ? Border.all(color: Colors.grey.shade300) : null,
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