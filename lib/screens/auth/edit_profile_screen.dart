import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_nomufinder/services/firebase_service.dart';
import 'package:project_nomufinder/viewmodels/input_viewmodel.dart';
import 'package:project_nomufinder/widgets/common_header.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _pushNotificationAgreed = false;

  final _genderKey = GlobalKey();
  final _ageKey = GlobalKey();
  final _employmentKey = GlobalKey();
  final _industryKey = GlobalKey();
  final _companySizeKey = GlobalKey();
  final _purposeKey = GlobalKey();

  String gender = '';
  String age = '';
  String employment = '';
  String industry = '';
  String companySize = '';
  String purpose = '';
  List<String> selectedIssues = [];
  List<String> infoNeeds = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final meta = await FirebaseService.getUserMeta();
    if (meta != null) {
      _nameController.text = meta['name'] ?? '';
      _emailController.text = meta['email'] ?? '';
      _phoneController.text = meta['phone'] ?? '';
      _pushNotificationAgreed = meta['pushNotificationAgreed'] ?? false;
    }

    final latestSurvey = await FirebaseService.getLatestSurveyResponse();
    if (latestSurvey != null) {
      setState(() {
        gender = latestSurvey['gender'] ?? '';
        age = latestSurvey['age'] ?? '';
        employment = latestSurvey['employment'] ?? '';
        industry = latestSurvey['industry'] ?? '';
        companySize = latestSurvey['companySize'] ?? '';
        purpose = latestSurvey['purpose'] ?? '';
        selectedIssues = List<String>.from(latestSurvey['selectedIssues'] ?? []);
        infoNeeds = List<String>.from(latestSurvey['infoNeeds'] ?? []);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await FirebaseService.updateUserProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      pushNotificationAgreed: _pushNotificationAgreed,
    );

    final updatedState = InputState(
      gender: gender,
      age: age,
      employment: employment,
      industry: industry,
      companySize: companySize,
      purpose: purpose,
      selectedIssues: selectedIssues,
      infoNeeds: infoNeeds,
    );
    await FirebaseService.updateLatestSurveyResponse(updatedState);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정보가 저장되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const CommonHeader(),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '내 정보 수정',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0010BA),
                  fontFamily: 'Open Sans',
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(_nameController, '이름', Icons.person),
              _buildTextField(_emailController, '이메일', Icons.email),
              _buildTextField(_phoneController, '휴대폰 번호', Icons.phone),
              const SizedBox(height: 8),
              Card(
                elevation: 0.5,
                margin: const EdgeInsets.symmetric(vertical: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  title: const Text('마케팅 수신 동의', style: TextStyle(fontFamily: 'Open Sans')),
                  value: _pushNotificationAgreed,
                  onChanged: (val) => setState(() => _pushNotificationAgreed = val),
                ),
              ),
              const SizedBox(height: 7),
              _buildDropdown(key: _genderKey, label: '성별', value: gender, items: ['여성', '남성', '제 3의 성'], onChanged: (val) {
                setState(() => gender = val ?? '');
                Future.delayed(const Duration(milliseconds: 200), () {
                  Scrollable.ensureVisible(_genderKey.currentContext!);
                });
              }),
              _buildDropdown(key: _ageKey, label: '연령대', value: age, items: ['10대', '20대', '30대', '40대', '50대', '60대 이상'], onChanged: (val) => setState(() => age = val ?? '')),
              _buildDropdown(key: _employmentKey, label: '고용형태', value: employment, items: [
                '정규직', '계약직/파견직', '아르바이트/단기근로', '자영업/프리랜서', '구직중', '은퇴', '기타'
              ], onChanged: (val) => setState(() => employment = val ?? '')),
              _buildDropdown(key: _industryKey, label: '업종', value: industry, items: [
                '서비스업 (음식점, 판매, 운송 등)', '제조업/생산직', '사무/관리직', 'IT/기술직', '건설/노무직', '교육/연구직', '보건/의료/사회복지', '프리랜서/플랫폼 노동자', '기타 ( )', '해당 없음'
              ], onChanged: (val) => setState(() => industry = val ?? '')),
              _buildDropdown(key: _companySizeKey, label: '사업장 규모', value: companySize, items: [
                '5인 미만', '5인 이상 ~ 30인 미만', '30인 이상 ~ 100인 미만', '100인 이상', '잘 모름 / 해당 없음'
              ], onChanged: (val) => setState(() => companySize = val ?? '')),
              _buildDropdown(key: _purposeKey, label: '이용 목적', value: purpose, items: [
                '현재 겪고 있는 노무 문제 해결', '평소 궁금했던 노무 상식이나 정보 얻기', '혹시 모를 상황에 대비하기 위해', '전문가(노무사)를 찾거나 연결되기 위해', '기타 ( )'
              ], onChanged: (val) => setState(() => purpose = val ?? '')),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0024EE).withOpacity(0.1), // 반투명 블루
                border: Border.all(color: const Color(0xFF0024EE), width: 1.5), // 선명한 테두리
                borderRadius: BorderRadius.circular(50),
              ),
              child: TextButton(
                onPressed: _save,
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                  foregroundColor: const Color(0xFF0024EE),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Open Sans',
                  ),
                ),
                child: const Text('저장하기'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'Open Sans'),
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required Key key,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: DropdownButtonFormField<String>(
        key: key,
        value: value.isNotEmpty ? value : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'Open Sans'),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontFamily: 'Open Sans')))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
