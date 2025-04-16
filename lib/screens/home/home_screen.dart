import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../viewmodels/search_viewmodel.dart';
import 'package:project_nomufinder/widgets/common_header.dart';

// 상수 정의
const Color searchBarBackgroundColor = Color(0xFFEBEBEB);
const double searchBarBorderRadius = 22.5;
const Color highlightedTextColor = Color(0xFFBD0101);
const double suggestionsBoxTop = 60;
const double suggestionsBoxHorizontalPadding = 16;
const double searchBarContentPaddingVertical = 12;
const double searchBarContentPaddingHorizontal = 20;

// 검색어에 따른 자동완성 목록을 제공하는 FutureProvider 정의
final suggestionsProvider =
FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.isEmpty || query.length < 2) return [];
  return await ApiService.getSuggestions(query); // ApiService의 getSuggestions 호출
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSuggestions = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 화면 UI 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const CommonHeader(),
        toolbarHeight: 56,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: suggestionsBoxHorizontalPadding, vertical: 20),
              children: [
                _buildSearchBar(context), // 검색창
                const SizedBox(height: 20),
                _buildCategorySection(context, ref),
                const SizedBox(height: 30),
                _buildQuickConsultation(),
                const SizedBox(height: 20),
                _buildConsultationCostCard(),
                const SizedBox(height: 20),
                _buildIssueIcons(),
                const SizedBox(height: 30),
                _buildSectionTitle('오늘의 소식'),
                _buildGrayContainer(height: 200),
                const SizedBox(height: 30),
                _buildSectionTitle('법률 정보'),
                _buildGrayContainer(height: 180),
                const SizedBox(height: 30),
                _buildSectionTitle('법정의무교육'),
                _buildGrayContainer(height: 180),
                const SizedBox(height: 40),
              ],
            ),
            if (_showSuggestions) _buildSuggestionsBox(),
          ],
        ),
      ),
    );
  }

  // 검색창 위젯
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: searchBarBackgroundColor,
        borderRadius: BorderRadius.circular(searchBarBorderRadius),
        border: Border.all(color: Colors.grey.shade300, width: 2), // Border for the search bar
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _showSuggestions = value.length >= 2;
          });
        },
        decoration: InputDecoration(
          hintText: '어떤 문제가 있으신가요?',
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _showSuggestions = false;
              });
            },
          )
              : null,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: searchBarContentPaddingHorizontal,
              vertical: searchBarContentPaddingVertical),
        ),
      ),
    );
  }

  // 사업주/근로자 버튼 섹션 위젯
  Widget _buildCategorySection(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _buildCategoryButton(context, ref, '사업주', 'employer'),
        const SizedBox(width: 16),
        _buildCategoryButton(context, ref, '근로자', 'worker'),
      ],
    );
  }

  // 사업주/근로자 버튼 위젯
  Widget _buildCategoryButton(
      BuildContext context, WidgetRef ref, String label, String userType) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(userTypeProvider.notifier).state = userType;
          context.push('/category-selection'); // 카테고리 선택 화면으로 이동
        },
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F1FA),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 자동완성 목록 위젯
  Widget _buildSuggestionsBox() {
    final suggestionsFuture =
    ref.watch(suggestionsProvider(_searchController.text));

    return Positioned(
      top: suggestionsBoxTop,
      left: suggestionsBoxHorizontalPadding,
      right: suggestionsBoxHorizontalPadding,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: suggestionsFuture.when(
            data: (suggestions) {
              if (suggestions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Center(child: Text("추천 검색어가 없습니다")),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ListTile(
                    title:
                    _buildHighlightedText(suggestion, _searchController.text),
                    dense: true,
                    onTap: () {
                      _searchController.text = suggestion;
                      setState(() {
                        _showSuggestions = false;
                      });
                      context.push('/search', extra: suggestion);
                    },
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(15),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) {
              debugPrint("Error fetching suggestions: $error\n$stack");
              return const Padding(
                padding: EdgeInsets.all(15),
                child: Center(child: Text("검색어 추천에 실패했습니다.")),
              );
            },
          ),
        ),
      ),
    );
  }

  // 검색어에서 입력된 텍스트와 일치하는 부분을 강조하는 위젯
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
            color: highlightedTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = startIndex + query.length;
    }

    return Text.rich(TextSpan(children: matches));
  }
}

// 간편 상담 UI 박스들 (빠른상담, 최신 글 등) 위젯
Widget _buildQuickConsultation() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: suggestionsBoxHorizontalPadding),
    child: Row(
      children: [
        _buildSmallBox('빠른 상담 ⚡'),
        const SizedBox(width: 10),
        _buildSmallBox('최신 상담글 🆕'),
        const SizedBox(width: 10),
        _buildSmallBox('상담글 작성 ✍️'),
      ],
    ),
  );
}

// 작은 박스 위젯
Widget _buildSmallBox(String text) {
  return Expanded(
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2F2),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}

// 회색 박스 (Placeholder 영역) 위젯
Widget _buildGrayContainer({required double height}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: suggestionsBoxHorizontalPadding),
    width: double.infinity,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

// 섹션 타이틀 위젯
Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: suggestionsBoxHorizontalPadding),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

// 근로 문제를 나타내는 대표 아이콘 목록 위젯
Widget _buildIssueIcons() {
  final issues = [
    {'icon': Icons.warning_amber_outlined, 'label': '부당해고'},
    {'icon': Icons.gavel, 'label': '부당징계'},
    {'icon': Icons.article, 'label': '근로계약'},
    {'icon': Icons.work_outline, 'label': '근무조건'},
    {
      'icon': Icons.block_outlined,
      'label': '직장 내\n성희롱'
    },
    {
      'icon': Icons.report_gmailerrorred_outlined,
      'label': '직장 내\n차별'
    },
    {'icon': Icons.mood_bad_outlined, 'label': '직장 내\n괴롭힘'},
    {'icon': Icons.attach_money, 'label': '임금/퇴직금'},
    {
      'icon': Icons.health_and_safety_outlined,
      'label': '산업재해'
    },
    {'icon': Icons.account_balance, 'label': '노동조합'},
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: suggestionsBoxHorizontalPadding),
    child: GridView.builder(
      itemCount: issues.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final issue = issues[index];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child:
              Icon(issue['icon'] as IconData, color: Colors.black87, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              issue['label'].toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w500, height: 1.2),
            ),
          ],
        );
      },
    ),
  );
}

// 상담 비용 안내 카드 위젯
Widget _buildConsultationCostCard() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: suggestionsBoxHorizontalPadding),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0010BA),
        borderRadius: BorderRadius.circular(11),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '노무사 상담 비용, 미리 확인하기!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6),
                Text(
                  '노무사 상담수수료 견적 받기',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6),
                Divider(color: Colors.white, thickness: 1, endIndent: 150),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              image: const DecorationImage(
                image: NetworkImage("https://placehold.co/60x60"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}