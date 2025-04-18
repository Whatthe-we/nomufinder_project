import 'package:flutter/material.dart';
import 'package:project_nomufinder/services/api_service.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/services/lawyer_data_loader.dart';
import 'package:project_nomufinder/screens/lawyer_search/lawyer_list_screen.dart';

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
        suggestions = response['suggestions']; // response: { category, suggestions }
      });
    } catch (e) {
      print("❌ 추천 실패: $e");
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
      appBar: AppBar(title: const Text("어떤 문제가 있으신가요?")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (value) {
                if (value.isNotEmpty) _fetchSuggestions(value);
              },
              decoration: const InputDecoration(
                hintText: '예시 : 일하다 다쳤어요',
                border: OutlineInputBorder(),
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
                    onTap: () => _onKeywordTap(keyword),
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