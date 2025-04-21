import 'package:flutter/material.dart';
import 'package:project_nomufinder/services/api_service.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/services/lawyer_data_loader.dart';
import 'package:project_nomufinder/screens/lawyer_search/lawyer_list_screen.dart';
import 'package:project_nomufinder/widgets/common_header.dart';
import 'package:project_nomufinder/viewmodels/search_viewmodel.dart';
import 'package:project_nomufinder/services/lawyer_service.dart';

class KeywordSearchScreen extends StatefulWidget {
  const KeywordSearchScreen({super.key});

  @override
  State<KeywordSearchScreen> createState() => _KeywordSearchScreenState();
}

class _KeywordSearchScreenState extends State<KeywordSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> suggestions = [];

  Future<void> _fetchSuggestions(String query) async {
    try {
      final response = await ApiService.getSuggestions(query);
      setState(() {
        suggestions = response['suggestions']; // API에서 받아온 추천 키워드
      });
    } catch (e) {
      print("❌ 자동완성 실패: $e");
    }
  }

  Future<void> _classifyAndNavigate(String keyword) async {
    try {
      // GPT 기반 분류 API 호출
      final category = await ApiService.classifyText(keyword);
      final normalized = normalizeCategory(category); // ✅ 정규화 필수

      // 카테고리 기반으로 노무사 필터링
      final allLawyers = lawyersByRegion.values.expand((list) => list).toList();
      final filtered = filterLawyersBySpecialty(normalized, allLawyers); // ✅ 필터 함수 사용

      // 해당 카테고리 노무사 리스트로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LawyerListScreen(
            title: category,
            category: normalized, // ✅ 정규화된 카테고리를 넘겨야 필터에 정상 반영
            lawyers: filtered,
          ),
        ),
      );
    } catch (e) {
      print("❌ 분류 및 이동 실패: $e");
    }
  }

  // 유사 키워드 매칭 함수
  bool _isTagMatching(String keyword, List<String> tags) {
    return tags.any((tag) =>
    tag.contains(keyword) || keyword.contains(tag)); // 양방향 대응
  }

  void _onKeywordTap(String keyword) {
    final filtered = lawyersByRegion.values
        .expand((list) => list)
        .where((lawyer) => _isTagMatching(keyword, lawyer.specialties))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LawyerListScreen(
          title: keyword,
          category: keyword,
          lawyers: filtered,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: true, // ← 뒤로가기 버튼 활성화
        title: const CommonHeader(), // ✅ 로고 포함 공통 헤더
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F2F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  if (value.isNotEmpty) _fetchSuggestions(value);
                },
                decoration: const InputDecoration(
                  hintText: '예시 : 잔업수당을 한 번도 받은 적이 없어요',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (suggestions.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "추천 키워드:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions.map((keyword) {
                  return GestureDetector(
                    onTap: () => _classifyAndNavigate(keyword),
                    child: Chip(
                      label: Text(keyword),
                      backgroundColor: const Color(0xFFEFEFFF),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}