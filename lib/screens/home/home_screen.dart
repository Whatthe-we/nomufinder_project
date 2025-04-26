import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../viewmodels/search_viewmodel.dart';
import 'package:project_nomufinder/widgets/common_header.dart';
import 'package:project_nomufinder/services/lawyer_data_loader.dart';
import 'package:project_nomufinder/screens/lawyer_search/lawyer_list_screen.dart';

import '../favorites/post_list_screen.dart';
import '../favorites/post_create_screen.dart';

// 상수 선언
const double suggestionsBoxHorizontalPadding = 16.0;

// ✅ 배너 데이터
final List<Map<String, String>> bannerData = [
  {'title': '노무무 배너', 'image': 'assets/images/banner1.png'},
  {'title': '5대 의무교육 배너', 'image': 'assets/images/banner2.png'},
  {'title': '리뷰 배너', 'image': 'assets/images/banner3.png'},
  {'title': '노무사 상담 배너', 'image': 'assets/images/banner4.png'},
];
// home_screen.dart 상단에 추가해줘!
final Map<String, List<String>> issueKeywordMap = {
  '직장 내 성희롱': ['성희롱', '직장내성희롱', '괴롭힘·성희롱'],
  '직장 내 괴롭힘': ['괴롭힘', '직장내괴롭힘', '괴롭힘·성희롱'],
  '근무조건': ['근무조건', '근로계약/근무조건 상담'],
  '근로계약': ['근로계약', '근로계약/근무조건 상담'],
  '임금/퇴직금': ['임금/퇴직금', '임금체불', '급여', '임금', '퇴직금'],
  '노동조합': ['노동조합'],
  '산업재해': ['산업재해'],
  '부당해고': ['부당해고'],
  '부당징계': ['부당징계'],
  '직장 내 차별': ['차별','왕따'],
};

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), _autoSlide);
  }

  void _autoSlide() {
    if (_pageController.hasClients) {
      int nextPage = (_currentPage + 1) % bannerData.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage = nextPage);
    }
    Future.delayed(const Duration(seconds: 5), _autoSlide);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const CommonHeader(),
        toolbarHeight: 56,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildSearchBar(context),
              const SizedBox(height: 20),
              _buildCategorySection(),
              const SizedBox(height: 20),
              _buildQuickConsultation(context),
              const SizedBox(height: 20),
              _buildPageViewBanner(),
              const SizedBox(height: 20),
              _buildIssueIcons(),
              const SizedBox(height: 30),
              _buildSectionTitle('오늘의 소식'),
              _buildGrayContainer(height: 200),
              const SizedBox(height: 30),
              _buildSectionTitle('알아두면 좋은 법률 정보'),
              _buildGrayContainer(height: 180),
              const SizedBox(height: 30),
              _buildSectionTitle('법정의무교육'),
              _buildGrayContainer(height: 180),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ PageView 배너
  Widget _buildPageViewBanner() {
    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: _pageController,
        itemCount: bannerData.length,
        itemBuilder: (context, index) {
          final banner = bannerData[index];
          return _buildBannerItem(banner['image']!);
        },
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
      ),
    );
  }

  Widget _buildBannerItem(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  // 사업주 & 근로자 버튼
  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildCategoryButton('사업주'),
          const SizedBox(width: 16),
          _buildCategoryButton('근로자'),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(userTypeProvider.notifier).state =
          label == '사업주' ? 'employer' : 'worker';
          if (label == '근로자') {
            context.go('/worker');
          }
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // 검색창
  // 수정된 검색창
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => context.go('/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F2F2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Color(0xFF0024EE), width: 2), // 파란색 두께 추가
          ),
          child: Row(
            children: const [
              Icon(Icons.search, color: Color(0xFF0024EE), size: 24),
              // 명확한 파란 아이콘
              SizedBox(width: 10),
              Text(
                '어떤 문제가 있으신가요?',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 빠른 상담 등
  Widget _buildQuickConsultation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildSmallBox('빠른 상담 ⚡', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('빠른 상담 준비 중')),
            );
          }),
          const SizedBox(width: 12),
          _buildSmallBox('최신 상담글 🆕', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostListScreen()),
            );
          }),
          const SizedBox(width: 12),
          _buildSmallBox('상담글 작성 ✍️', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostCreateScreen(
                  onPostCreated: (post) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('글 "${post.title}" 작성 완료!')),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }



  Widget _buildSmallBox(String text, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFFD),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrayContainer({required double height}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildIssueIcons() {
    final issues = [
      {'icon': Icons.warning_amber_outlined, 'label': '부당해고'},
      {'icon': Icons.gavel, 'label': '부당징계'},
      {'icon': Icons.article, 'label': '근로계약'},
      {'icon': Icons.work_outline, 'label': '근무조건'},
      {'icon': Icons.block_outlined, 'label': '직장 내\n성희롱'},
      {'icon': Icons.report_gmailerrorred_outlined, 'label': '직장 내\n차별'},
      {'icon': Icons.mood_bad_outlined, 'label': '직장 내\n괴롭힘'},
      {'icon': Icons.attach_money, 'label': '임금/퇴직금'},
      {'icon': Icons.health_and_safety_outlined, 'label': '산업재해'},
      {'icon': Icons.account_balance, 'label': '노동조합'},
    ];

    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(
          horizontal: suggestionsBoxHorizontalPadding, vertical: 16),
      child: GridView.builder(
        itemCount: issues.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final issue = issues[index];
          final label = issue['label'] as String;

          return GestureDetector(
            onTap: () {
              // 필터링 로직 (WorkerIssueScreen과 동일)
              final filtered = lawyersByRegion.values
                  .expand((list) => list)
                  .where((lawyer) {
                final normalized = normalizeCategory(label);
                final keywords = issueKeywordMap[normalized] ?? [label.trim()];
                return lawyer.specialties.any((tag) {
                  return keywords.any((keyword) =>
                  tag.contains(keyword) || keyword.contains(tag)); // 🔥 양방향 비교!
                });
              }).toList();

              // LawyerListScreen으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LawyerListScreen(
                        title: label,
                        category: label,
                        lawyers: filtered,
                      ),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 22,
                  child: Icon(issue['icon'] as IconData, color: Colors.black87,
                      size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500, height: 1.3),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}