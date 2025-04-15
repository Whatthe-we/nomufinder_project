import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../viewmodels/search_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> suggestions = []; // 자동완성 목록
  String selectedCategory = "";  // 선택된 카테고리

  @override
  void initState() {
    super.initState();
  }

  // 사용자가 입력한 값에 따라 관련 단어 목록 업데이트
  void _updateSuggestions(String query) async {
    if (query.isNotEmpty) {
      try {
        // API 호출하여 관련 단어 목록을 받아오기
        final response = await ApiService.getSuggestions(query);
        print("Suggestions: $response");  // 받아온 단어 목록 출력

        setState(() {
          suggestions = response; // 받아온 목록으로 갱신
        });
      } catch (e) {
        print("자동완성 요청 실패: $e");
      }
    } else {
      setState(() {
        suggestions = []; // 입력이 비었을 때는 자동완성 목록을 비워줍니다.
      });
    }
  }

  // 카테고리 클릭 시 해당 카테고리에 맞는 노무사 목록 보여주기
  void _selectCategory(String category) async {
    final laborAttorneys = await ApiService.getLaborAttorneysByCategory(category);

    // 노무사 이름만 추출해서 List<String>으로 변환
    final attorneyNames = laborAttorneys.map((attorney) => attorney['name'] as String).toList();

    // 선택된 카테고리와 노무사 목록을 화면에 표시
    setState(() {
      selectedCategory = category;
    });

    // 화면에서 노무사 목록을 보여주는 UI 추가
    _showLaborAttorneyList(attorneyNames);
  }

  void _showLaborAttorneyList(List<String> attorneyNames) {
    // 여기에 UI를 업데이트하여 선택된 카테고리에 맞는 노무사 목록을 표시하도록 함
    // 예를 들어, 리스트를 표시하는 부분을 추가하거나 다른 화면으로 넘길 수 있음
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('선택된 카테고리: $selectedCategory'),
        content: Column(
          children: attorneyNames.map((name) => Text(name)).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(categoryProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 10),
            if (selectedCategory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("📌 선택된 카테고리: $selectedCategory",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 20),
            if (suggestions.isNotEmpty) _buildSuggestionsList(),
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
        ),
      ),
    );
  }

  // 자동완성 목록 출력
  Widget _buildSuggestionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            // 선택된 항목을 카테고리로 설정
            _selectCategory(suggestions[index]);
          },
        );
      },
    );
  }

  /// 텍스트 입력 가능한 검색창 (아이콘 + onChanged)
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: _updateSuggestions, // 텍스트가 변경될 때마다 자동완성 업데이트
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: '어떤 문제가 있으신가요?',
          suffixIcon: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              final result = await ApiService.classifyText(_searchController.text);
              ref.read(categoryProvider.notifier).state = result;
            },
          ),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  // 헤더 (앱 타이틀 / 로그인/가입)
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

  // 회색 박스 (Placeholder 영역)
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

  // 섹션 타이틀
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

  // 카테고리 섹션 (사업주, 근로자)
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
          ref.read(userTypeProvider.notifier).state = label == '사업주' ? 'employer' : 'worker';
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

  // 빠른 상담 / 최신 상담글 / 상담글 작성 영역
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

  // 노무사 상담수수료 견적 카드
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

  // 아이콘 + 텍스트 10개 (2행 × 5열)
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
}