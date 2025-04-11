import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  // 예시용 dummy 데이터 (실제 API 연동 시 데이터를 여기서 대체)
  final List<String> _allItems = [
    "노동법",
    "근로계약",
    "부당해고",
    "노무 상담",
    "임금",
    "퇴직금",
    "산업재해",
    "노동조합",
    "휴가",
    "근무조건",
  ];

  List<String> get _searchResults {
    if (_searchQuery.isEmpty) {
      return [];
    }
    return _allItems
        .where((item) =>
        item.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // 검색어가 있으면 검색 결과, 없으면 기존 홈 콘텐츠 표시
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 20),
            if (_searchQuery.isNotEmpty)
              _buildSearchResults()
            else ...[
              _buildCategorySection(),
              const SizedBox(height: 20),
              _buildQuickConsultation(),
              const SizedBox(height: 20),
              _buildConsultationCostCard(),
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
          ],
        ),
      ),
    );
  }

  /// 헤더 (앱 타이틀 / 로그인/가입)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'NOMU FINDER',
            style: TextStyle(
              color: const Color(0xFF000FBA),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          const Spacer(),
          Text(
            '로그인/가입',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 텍스트 입력 가능한 검색창 (아이콘 + onChanged)
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: '어떤 문제가 있으신가요?',
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.5),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          fillColor: const Color(0xFFF4F2F2),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// 검색 결과 영역
  Widget _buildSearchResults() {
    final results = _searchResults;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        // 결과가 많아지면 최대 높이를 제한하여 스크롤 가능하게 만듦.
        constraints: const BoxConstraints(maxHeight: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: results.isNotEmpty
            ? ListView.separated(
          shrinkWrap: true,
          itemCount: results.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                results[index],
                style: const TextStyle(fontSize: 16),
              ),
              onTap: () {
                // 검색 결과 선택 시 동작 (필요 시)
                // 예: context.go('/searchResult', extra: results[index]);
              },
            );
          },
        )
            : const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('검색 결과가 없습니다.'),
        ),
      ),
    );
  }

  /// 카테고리 섹션 (사업주, 근로자)
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
    );
  }

  /// 빠른 상담 / 최신 상담글 / 상담글 작성 영역
  Widget _buildQuickConsultation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// 노무사 상담수수료 견적 카드
  Widget _buildConsultationCostCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0010BA),
          borderRadius: BorderRadius.circular(11),
        ),
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '노무사 상담 비용, 미리 확인하기!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '노무사 상담수수료 견적 받기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 120,
                    height: 1,
                    color: Colors.white,
                  ),
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

  /// 아이콘 + 텍스트 10개 (2행 × 5열)
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                child: Icon(
                  issue['icon'] as IconData,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                issue['label'].toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 회색 박스 (Placeholder 영역)
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

  /// 섹션 타이틀
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 29ffeda04d0a7f93d2ee20552ea24665f81d379a
