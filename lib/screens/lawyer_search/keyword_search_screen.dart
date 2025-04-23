import 'dart:async';
import 'dart:math';
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

  // ✅ 예시 문장 리스트 및 상태
  final List<String> examplePrompts = [
    "수습 끝나자마자 나오지 말래요 ㅋㅋ",
    "출산휴가 갔다 왔더니 자리 없어짐",
    "급여가 그냥 깎였어요",
    "회사가 나이로 차별하는 것 같아요",
    "정년 전에 퇴사 권유 받았어요",
    "휴가 쓰면 월급 깎이던데요?",
    "근로계약서 작성한 적 없어요",
    "야근수당? 그런 거 한 번도 못 받음",
    "계약 연장 걍 안 해준다네요...",
    "노조 가입했더니 눈치 엄청 주네요",
    "상사가 외모 얘기 계속 해요",
    "출근하다 교통사고 났는데 제가 돈내요?",
  ];
  String currentPrompt = "";
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _setRandomPrompt();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _setRandomPrompt();
    });
  }

  void _setRandomPrompt() {
    final random = Random();
    setState(() {
      currentPrompt = examplePrompts[random.nextInt(examplePrompts.length)];
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final response = await ApiService.getSuggestions(query);
      setState(() {
        suggestions = response['suggestions'];
      });
    } catch (e) {
      print("❌ 자동완성 실패: $e");
    }
  }

  Future<void> _classifyAndNavigate(String keyword) async {
    try {
      // GPT 기반 분류 API 호출
      final category = await ApiService.classifyText(keyword);
      final normalized = normalizeCategory(category); // 정규화

      // 카테고리 기반으로 노무사 필터링
      final allLawyers = lawyersByRegion.values.expand((list) => list).toList();
      final filtered = filterLawyersBySpecialty(normalized, allLawyers); // 필터 함수 사용

      // 해당 카테고리 노무사 리스트로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LawyerListScreen(
            title: category,
            category: normalized, // 정규화된 카테고리 넘겨 필터링
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
        title: const CommonHeader(), // 로고 포함 공통 헤더
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const AnimatedLogoBanner(), // ✅ 애니메이션 로고 추가!
            const SizedBox(height: 27),

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
                  hintText: '원하는 내용을 입력해보세요',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ 예시 문구 애니메이션
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  final fadeAnimation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation);

                  final scaleAnimation = Tween<double>(
                    begin: 0.95,
                    end: 1.0,
                  ).animate(animation);

                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: ScaleTransition(
                        scale: scaleAnimation,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Text(
                  currentPrompt,
                  key: ValueKey(currentPrompt),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),

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

// ✅ 아래는 로고 애니메이션 위젯 (Slide 위아래로 이동)
class AnimatedLogoBanner extends StatefulWidget {
  const AnimatedLogoBanner({super.key});

  @override
  State<AnimatedLogoBanner> createState() => _AnimatedLogoBannerState();
}

class _AnimatedLogoBannerState extends State<AnimatedLogoBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0.05),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 10),
          const Text(
            "어떤 문제가 있으신가요?",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}