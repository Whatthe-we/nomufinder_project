import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../viewmodels/search_viewmodel.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/screens/lawyer_search/lawyer_list_screen.dart';

class KeywordSearchScreen extends ConsumerStatefulWidget {
  const KeywordSearchScreen({super.key});

  @override
  ConsumerState<KeywordSearchScreen> createState() => _KeywordSearchScreenState();
}

class _KeywordSearchScreenState extends ConsumerState<KeywordSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Future<List<String>>? _suggestionsFuture;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _onSearchChanged(_controller.text));
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _suggestionsFuture = ApiService.getSuggestions(query);
      });
    } else {
      setState(() {
        _suggestionsFuture = Future.value([]);
      });
    }
  }

  // _buildSuggestionsList 메서드를 정의
  Widget _buildSuggestionsList() {
    return FutureBuilder<List<String>>(
      future: _suggestionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('자동완성 목록을 불러오는 데 실패했습니다.'));
        } else if (snapshot.data?.isEmpty ?? true) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('추천 검색어가 없습니다.'),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true, // 부모 위젯의 크기에 맞춰 크기 조정
            physics: const BouncingScrollPhysics(), // 스크롤 시 탄력 효과
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final suggestion = snapshot.data![index];
              return GestureDetector(
                onTap: () {
                  _onSelectSuggestion(suggestion);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildHighlightedText(suggestion, _controller.text),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  // 검색어와 일치하는 부분을 빨간색으로 강조하는 함수
  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(text);
    }

    final lowerCaseText = text.toLowerCase();
    final lowerCaseQuery = query.toLowerCase();
    final matches = <TextSpan>[];
    var start = 0;

    while (start < text.length) {
      final startIndex = lowerCaseText.indexOf(lowerCaseQuery, start);
      if (startIndex == -1) {
        matches.add(TextSpan(text: text.substring(start)));
        break;
      }

      matches.add(TextSpan(text: text.substring(start, startIndex)));
      matches.add(
        TextSpan(
          text: text.substring(startIndex, startIndex + query.length),
          style: const TextStyle(
            color: Color(0xFFBD0101), // 빨간색 강조
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = startIndex + query.length;
    }

    return Text.rich(TextSpan(children: matches));
  }

  void _onSelectSuggestion(String text) async {
    _controller.text = text;
    final selectedCategory = await ApiService.classifyText(text);

    if (selectedCategory == "카테고리를 찾을 수 없습니다") {
      print("카테고리 추출 실패");
      return;
    }

    final laborAttorneys = await ApiService.getLaborAttorneysBySpecialty(selectedCategory);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LawyerListScreen(
          title: selectedCategory,
          lawyers: laborAttorneys,
          category: selectedCategory,
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
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('어떤 문제가 있으신가요?', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBEB),
                borderRadius: BorderRadius.circular(22.5),
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: '일을 하다가 다리를 다쳤어요',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        _suggestionsFuture = Future.value([]);
                      });
                    },
                  )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildSuggestionsList()), // 여기서 자동완성 목록을 표시합니다.
          ],
        ),
      ),
    );
  }
}