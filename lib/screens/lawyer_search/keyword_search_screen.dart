import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_nomufinder/services/api_service.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/services/lawyer_data_loader.dart';
import 'package:project_nomufinder/screens/lawyer_search/lawyer_list_screen.dart';
import 'package:project_nomufinder/widgets/common_header.dart';
import 'package:project_nomufinder/viewmodels/search_viewmodel.dart';
import 'package:project_nomufinder/services/lawyer_service.dart';

// 🔥 Flutter용 고정 키워드 → 카테고리 매핑 (생략 가능 시 생략 가능)

class KeywordSearchScreen extends StatefulWidget {
  const KeywordSearchScreen({super.key});

  @override
  State<KeywordSearchScreen> createState() => _KeywordSearchScreenState();
}

class _KeywordSearchScreenState extends State<KeywordSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> suggestions = [];
  int? tappedIndex;

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
    if (_controller.text.isEmpty) {
      final random = Random();
      setState(() {
        currentPrompt = examplePrompts[random.nextInt(examplePrompts.length)];
      });
    }
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
      final category = await ApiService.classifyText(keyword);
      final normalized = normalizeCategory(category);

      final allLawyers = lawyersByRegion.values.expand((list) => list).toList();
      final filtered = filterLawyersBySpecialty(normalized, allLawyers);

      context.push('/lawyer_list', extra: {
        'category': normalized,
        'title': category,
        'lawyers': filtered,
      });
    } catch (e) {
      print("❌ 분류 및 이동 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const CommonHeader(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AnimatedLogoBanner(),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.only(left: 20, right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F2F2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Color(0xFF0024EE), width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 550),
                        transitionBuilder: (child, animation) {
                          final fadeAnimation = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          );
                          final slideAnimation = Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(animation);

                          return FadeTransition(
                            opacity: fadeAnimation,
                            child: SlideTransition(
                              position: slideAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          currentPrompt,
                          key: ValueKey(currentPrompt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    TextField(
                      controller: _controller,
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            _setRandomPrompt();
                          } else {
                            currentPrompt = '';
                          }
                        });
                        if (value.isNotEmpty) {
                          _fetchSuggestions(value);
                        } else {
                          setState(() {
                            suggestions = [];
                          });
                        }
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Color(0xFF0024EE)),
                        hintText: '',
                      ),
                    ),
                    Positioned(
                      right: 1,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Color(0xFF0024EE)),
                        onPressed: () {
                          final inputText = _controller.text.trim();
                          if (inputText.isNotEmpty) {
                            _classifyAndNavigate(inputText);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              if (suggestions.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "인기 키워드",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 45,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: suggestions.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final keyword = suggestions[index];
                      return GestureDetector(
                        onTap: () => _classifyAndNavigate(keyword),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              keyword,
                              style: const TextStyle(color: Colors.black87, fontSize: 14),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "키워드를 누르면 딱 맞는 노무사를 추천해드려요",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// 애니메이션 로고 위젯
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
      end: const Offset(0, 0.07),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        SlideTransition(
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
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
