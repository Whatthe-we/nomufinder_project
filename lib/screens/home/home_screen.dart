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

import 'package:project_nomufinder/viewmodels/youtube_viewmodel.dart';
import 'package:project_nomufinder/widgets/youtube_card.dart';
import 'package:project_nomufinder/models/youtube_video.dart';
import 'package:project_nomufinder/screens/banner/banner_detail_screen.dart';

// 상수 선언
const double suggestionsBoxHorizontalPadding = 16.0;

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

// 배너 데이터
final List<Map<String, String>> bannerData = [
  {'title': '노무무 배너', 'image': 'assets/images/banner1.png'},
  {'title': '5대 의무교육 배너', 'image': 'assets/images/banner2.png'},
  {'title': '리뷰 배너', 'image': 'assets/images/banner3.png'},
  {'title': '노무사 상담 배너', 'image': 'assets/images/banner4.png'},
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 종료 확인'),
        content: const Text('정말로 앱을 종료하시겠습니까?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // false를 반환하면 앱 종료 안 함
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // true를 반환하면 앱 종료
            child: const Text('종료'),
          ),
        ],
      ),
    ) ?? false; // showDialog가 null을 반환할 경우 (예: 다이얼로그 외부를 탭한 경우) false 반환
  }

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
    return WillPopScope( // WillPopScope로 감싸기
        onWillPop: _onWillPop,
        child: Scaffold(
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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


              // 📝 상황별 찾기 제목
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "상황별 찾기",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              _buildIssueIcons(),
              const SizedBox(height: 30),

              _buildSectionTitle('오늘의 소식'),
              _buildYoutubeNews(),
              const SizedBox(height: 30),

              _buildSectionTitle('알아두면 좋은 법률 정보'),
              _buildMergedLawInfoSection(),
              const SizedBox(height: 30),

              _buildSectionTitle('법정의무교육'),
              const SizedBox(height: 5),
              _buildYoutubePlaylistSection('PLRxCdWcfSSnpfw9auYADoTsVAGkQGZsd7', isEducation: true), // 법정의무교육
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
        )
    );
  }

// PageView Banner
  Widget _buildPageViewBanner() {
    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: _pageController,
        itemCount: bannerData.length,
        itemBuilder: (context, index) {
          final banner = bannerData[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BannerDetailScreen(
                    title: banner['title']!,
                    imagePath: banner['image']!,  // 여기 imagePath로 수정
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                banner['image']!,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
      ),
    );
  }



  // 사업주 & 근로자 Buttons
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

  // Search Bar
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
            border: Border.all(color: const Color(0xFF0024EE), width: 2),
          ),
          child: Row(
            children: const [
              Icon(Icons.search, color: Color(0xFF0024EE), size: 24),
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

  // Quick Consultation Buttons
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

  // 1) 뉴스 섹션
  Widget _buildYoutubeNews() {
    return SizedBox(
      width: double.infinity,
      height: 310,
      child: Consumer(
        builder: (context, ref, _) {
          final youtubeAsync = ref.watch(youtubeNewsProvider);

          return youtubeAsync.when(
            data: (videos) => PageView.builder(
              itemCount: videos.length > 5 ? 5 : videos.length,
              controller: PageController(viewportFraction: 1),
              itemBuilder: (context, index) {
                return YoutubeCard(
                  video: videos[index],
                  width: 500,
                  thumbnailHeight: 200,
                  variant: 'news',
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Center(child: Text('유튜브 뉴스 로딩 실패')),
          );
        },
      ),
    );
  }

  // 2) 법률정보 섹션
  List<YoutubeVideo>? _cachedMergedVideos;
  DateTime? _lastShuffleTime;

  Widget _buildMergedLawInfoSection() {
    final asyncVideos1 = ref.watch(youtubePlaylistProvider('PLw3rGaCM7CWWWVmo4NciygQdoOLV95n0Q'));
    final asyncVideos2 = ref.watch(youtubePlaylistProvider('PLw3rGaCM7CWXNty2HKfoLJZC6-o0rzoPr'));

    return SizedBox(
      height: 250,
      child: asyncVideos1.when(
        data: (videos1) => asyncVideos2.when(
          data: (videos2) {
            final now = DateTime.now();
            if (_cachedMergedVideos == null ||
                _lastShuffleTime == null ||
                now.difference(_lastShuffleTime!).inMinutes >= 30) {
              _cachedMergedVideos = [...videos1, ...videos2]..shuffle();
              _lastShuffleTime = now;
            }

            final mergedVideos = _cachedMergedVideos!;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mergedVideos.length,
              itemBuilder: (context, index) {
                return YoutubeCard(
                  video: mergedVideos[index],
                  width: 220,
                  thumbnailWidth: 100,
                  thumbnailHeight: 140,
                  variant: 'law',
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Center(child: Text('법률정보(이노무지식) 불러오기 실패')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('법률정보(랜선노동법) 불러오기 실패')),
      ),
    );
  }

  // 3) 법정의무교육 섹션
  Widget _buildYoutubePlaylistSection(
      String playlistId, {
        bool isEducation = false,
      }) {
    final asyncVideos = ref.watch(youtubePlaylistProvider(playlistId));

    return SizedBox(
      height: isEducation ? 300 : null,
      child: asyncVideos.when(
        data: (videos) {
          if (isEducation) {
            return Scrollbar( // 스크롤바 추가
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return YoutubeCard(
                    video: videos[index],
                    isHorizontal: true,
                    thumbnailHeight: 100,
                    thumbnailWidth: 140,
                    variant: 'edu',
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  );
                },
              ),
            );
          } else {
            return const SizedBox();
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('법정의무교육 영상 불러오기 실패')),
      ),
    );
  }

  // Gray Container
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

  // Section Title
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

  // Issue Icons
  Widget _buildIssueIcons() {
    final issues = [
      {'icon': Icons.warning_amber_outlined, 'label': '부당해고\n '},
      {'icon': Icons.gavel, 'label': '부당징계\n '},
      {'icon': Icons.article, 'label': '근로계약\n '},
      {'icon': Icons.work_outline, 'label': '근무조건\n '},
      {'icon': Icons.cancel_outlined, 'label': '직장 내\n성희롱'},
      {'icon': Icons.do_disturb_on_outlined, 'label': '직장 내\n차별'},
      {'icon': Icons.mood_bad_outlined, 'label': '직장 내\n괴롭힘'},
      {'icon': Icons.attach_money, 'label': '임금/퇴직금\n '},
      {'icon': Icons.health_and_safety_outlined, 'label': '산업재해\n '},
      {'icon': Icons.groups_outlined, 'label': '노동조합\n '},
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
              final normalized = normalizeCategory(label);
              final keywords = issueKeywordMap[normalized] ?? [label.trim()];
              final filtered = lawyersByRegion.values
                  .expand((list) => list)
                  .where((lawyer) => lawyer.specialties.any((tag) =>
                  keywords.any((keyword) =>
                  tag.contains(keyword) || keyword.contains(tag))))
                  .toList();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LawyerListScreen(
                    title: label,
                    category: label,
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
                  child: Icon(issue['icon'] as IconData,
                      color: Colors.black87, size: 20),
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
// Issue Icons
Widget _buildIssueIcons() {
  final issues = [
    {'icon': Icons.warning_amber_outlined, 'label': '부당해고'},
    {'icon': Icons.gavel_outlined, 'label': '부당징계'},
    {'icon': Icons.description_outlined, 'label': '근로계약'},
    {'icon': Icons.schedule_outlined, 'label': '근무조건'},
    {'icon': Icons.block_outlined, 'label': '직장 내\n성희롱'},
    {'icon': Icons.do_disturb_alt_outlined, 'label': '직장 내\n차별'},
    {'icon': Icons.mood_bad_outlined, 'label': '직장 내\n괴롭힘'},
    {'icon': Icons.money_off_csred_outlined, 'label': '임금/퇴직금'},
    {'icon': Icons.health_and_safety_outlined, 'label': '산업재해'},
    {'icon': Icons.groups_outlined, 'label': '노동조합'},
  ];

  return Container(
    color: Colors.grey[100],
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: GridView.builder(
      itemCount: issues.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final issue = issues[index];
        final label = issue['label'] as String;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  issue['icon'] as IconData,
                  color: const Color(0xFF555555),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                    height: 1.3,
                  ),
                  maxLines: 2,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}





