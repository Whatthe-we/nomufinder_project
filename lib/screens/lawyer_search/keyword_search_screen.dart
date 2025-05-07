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

// 🔥 Flutter용 고정 키워드 → 카테고리 매핑
const Map<String, String> keywordToCategoryMap = {
  // 부당해고
  "해고": "부당해고",
  "해고예고수당": "부당해고",
  "수습기간 해고": "부당해고",
  "권고사직": "부당해고",
  "부당해고 기준": "부당해고",
  "해고 실업급여": "부당해고",
  "해고사유": "부당해고",
  "부당해고 사례": "부당해고",
  "정규직 해고": "부당해고",
  "부당해고 구제신청": "부당해고",

  // 부당징계
  "징계": "부당징계",
  "정직": "부당징계",
  "감봉": "부당징계",
  "경고": "부당징계",
  "징계위원회": "부당징계",
  "징계사유 미통보": "부당징계",
  "징계절차 위반": "부당징계",
  "이중징계": "부당징계",
  "대기발령": "부당징계",

  // 근로계약
  "근로계약서 미작성": "근로계약",
  "근로계약서 작성시기": "근로계약",
  "근로계약서 위반": "근로계약",
  "아르바이트 근로계약서 양식": "근로계약",
  "근로계약 만료 통보서": "근로계약",
  "근로계약 해지": "근로계약",
  "무기계약직 전환": "근로계약",
  "불리한 계약 조건": "근로계약",
  "수습 계약서": "근로계약",
  "계약 연장 거절": "근로계약",

  // 근무조건
  "근로조건": "근무조건",
  "근무조건 변경": "근무조건",
  "근무조건 실업급여": "근무조건",
  "근무조건 변경 퇴사": "근무조건",
  "근무조건 변경 퇴직금": "근무조건",
  "근무조건 다름": "근무조건",
  "주휴수당 미지급": "근무조건",
  "유급휴가": "근무조건",
  "교대근무": "근무조건",
  "초과근무 강요": "근무조건",

  // 직장내성희롱
  "성희롱": "직장내성희롱",
  "성추행": "직장내성희롱",
  "성희롱 예방교육": "직장내성희롱",
  "성희롱 처벌": "직장내성희롱",
  "성희롱 피해 입증": "직장내성희롱",
  "성희롱 신고": "직장내성희롱",
  "성희롱 사례": "직장내성희롱",
  "성희롱 퇴사": "직장내성희롱",
  "성희롱 실업급여": "직장내성희롱",
  "성희롱 2차 가해": "직장내성희롱",

  // 직장내괴롭힘
  "괴롭힘": "직장내괴롭힘",
  "직장 내 괴롭힘 처벌": "직장내괴롭힘",
  "직장 내 괴롭힘 증거": "직장내괴롭힘",
  "괴롭힘 사례": "직장내괴롭힘",
  "직장 내 괴롭힘 실업급여": "직장내괴롭힘",
  "괴롭힘 퇴사": "직장내괴롭힘",
  "괴롭힘 처벌기준": "직장내괴롭힘",
  "직장 내 괴롭힘 무고": "직장내괴롭힘",
  "직장 내 괴롭힘 신고": "직장내괴롭힘",
  "직장 내 왕따": "직장내괴롭힘",

  // 직장내차별
  "차별": "직장내차별",
  "성차별": "직장내차별",
  "나이 차별": "직장내차별",
  "출산휴가 불이익": "직장내차별",
  "출산휴가": "직장내차별",
  "육아휴직 불이익": "직장내차별",
  "육아휴직": "직장내차별",
  "직무 차별": "직장내차별",
  "기간제 차별": "직장내차별",
  "비정규직 차별": "직장내차별",
  "장애인 차별": "직장내차별",
  "업무 배정 차별": "직장내차별",

  // 임금/퇴직금
  "최저임금": "임금/퇴직금",
  "임금체불 신고": "임금/퇴직금",
  "임금피크제": "임금/퇴직금",
  "임금 뜻": "임금/퇴직금",
  "평균임금": "임금/퇴직금",
  "최저임금 위반": "임금/퇴직금",
  "퇴직금 지급기준": "임금/퇴직금",
  "퇴직금 계산": "임금/퇴직금",
  "퇴직금 지급기한": "임금/퇴직금",
  "퇴직금 세금": "임금/퇴직금",
  "퇴직금 IRP": "임금/퇴직금",
  "퇴직금 미지급 신고": "임금/퇴직금",

  // 산업재해
  "산재": "산업재해",
  "산업재해조사표": "산업재해",
  "중대산업재해": "산업재해",
  "산업재해 보상": "산업재해",
  "산업재해 기록 보존 기간": "산업재해",
  "산업안전보건법": "산업재해",
  "중대재해처벌법": "산업재해",
  "출퇴근 사고": "산업재해",
  "산업안전교육": "산업재해",
  "산업안전 컨설팅": "산업재해",

  // 노동조합
  "노조": "노동조합",
  "노동조합 뜻": "노동조합",
  "파업": "노동조합",
  "단체교섭": "노동조합",
  "임금 협상": "노동조합",
  "노동조합 교육": "노동조합",
  "교섭대표 노조": "노동조합",
  "노조 활동 불이익": "노동조합",
  "근로시간 면제제도": "노동조합",
  "노동조합비": "노동조합",

  // 기업자문
  "기업 노무자문": "기업자문",
  "노무법인 자문": "기업자문",
  "노무사 자문계약": "기업자문",
  "노무 대행": "기업자문",
  "인사규정 정비": "기업자문",
  "임금체계 개편": "기업자문",
  "취업규칙 제개정": "기업자문",
  "근로감독 대응": "기업자문",
  "노사관계 전략": "기업자문",
  "노동법 개정 대응": "기업자문",

  // 컨설팅
  "인사노무 컨설팅": "컨설팅",
  "노무사 컨설팅": "컨설팅",
  "노무 컨설팅 비용": "컨설팅",
  "급여 컨설팅": "컨설팅",
  "IT 컨설팅": "컨설팅",
  "성과관리 컨설팅": "컨설팅",
  "직무분석 컨설팅": "컨설팅",
  "ESG 컨설팅": "컨설팅",
  "평가제도 컨설팅": "컨설팅",
  "채용 컨설팅": "컨설팅",

  // 급여아웃소싱
  "급여 프로그램": "급여아웃소싱",
  "급여 관리": "급여아웃소싱",
  "급여 대행": "급여아웃소싱",
  "노무법인 급여 아웃소싱": "급여아웃소싱",
  "급여 아웃소싱 후기": "급여아웃소싱",
  "급여 아웃소싱 수수료": "급여아웃소싱",
  "퇴직금 정산": "급여아웃소싱",
  "4대 보험 신고 대행": "급여아웃소싱",
  "4대보험 및 원천징수": "급여아웃소싱",
  "급여 명세서 발급": "급여아웃소싱",
};

class KeywordSearchScreen extends StatefulWidget {
  const KeywordSearchScreen({super.key});

  @override
  State<KeywordSearchScreen> createState() => _KeywordSearchScreenState();
}

class _KeywordSearchScreenState extends State<KeywordSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> suggestions = [];
  int? tappedIndex;

  // 예시 문장 리스트 및 상태
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
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      _setRandomPrompt();
    });
  }

  void _setRandomPrompt() {
    if (_controller.text.isEmpty) { // 입력창 비었을 때만 예시 갱신
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
      // 1️⃣ 강제 매핑 먼저 체크
      final mappedCategory = keywordToCategoryMap[keyword];
      String finalCategory;

      if (mappedCategory != null) {
        // 매핑된 카테고리로 바로 이동
        finalCategory = mappedCategory;
      } else {
        // 2️⃣ 매핑 없으면 GPT API 분류
        final category = await ApiService.classifyText(keyword);
        finalCategory = normalizeCategory(category);
      }

      // 카테고리 기반 노무사 필터링
      final allLawyers = lawyersByRegion.values.expand((list) => list).toList();
      final filtered = filterLawyersBySpecialty(finalCategory, allLawyers);

      // 이동
      context.push('/lawyer_list', extra: {
        'category': finalCategory,
        'title': finalCategory,
        'lawyers': filtered,
      });
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
        builder: (_) =>
            LawyerListScreen(
              title: keyword,
              category: keyword,
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
                        icon: const Icon(Icons.arrow_forward, color: Color(
                            0xFF0024EE)),
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
                    separatorBuilder: (context, index) =>
                    const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final keyword = suggestions[index];
                      return GestureDetector(
                        onTapDown: (_) {
                          setState(() {
                            tappedIndex = index;
                          });
                        },
                        onTapUp: (_) {
                          setState(() {
                            tappedIndex = null;
                          });
                        },
                        onTapCancel: () {
                          setState(() {
                            tappedIndex = null;
                          });
                        },
                        onTap: () => _classifyAndNavigate(keyword),
                        child: AnimatedScale(
                          scale: tappedIndex == index ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                keyword,
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 14),
                              ),
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

// 로고 애니메이션 위젯
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
    )
      ..repeat(reverse: true);

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
        const SizedBox(height: 8), // 로고 위치 조정
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