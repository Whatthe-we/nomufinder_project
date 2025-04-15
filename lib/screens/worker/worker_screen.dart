import 'package:flutter/material.dart';
import 'package:project_nomufinder/widgets/common_header.dart'; // 너의 실제 프로젝트명 기준으로 수정했어
import 'worker_issue_screen.dart';
import 'worker_region_tab.dart';

class WorkerScreen extends StatelessWidget {
  const WorkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // ✅ 상단 고정 헤더 + 탭바 포함
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          // ✅ 공통 헤더 추가
          title: const CommonHeader(),
          toolbarHeight: 60,
          automaticallyImplyLeading: false, // ← 뒤로가기 버튼 제거
          bottom: const TabBar(
            labelColor: Color(0xFF000FBA),
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            indicatorColor: Color(0xFF000FBA),
            tabs: [
              Tab(text: '상황별 찾기'),
              Tab(text: '지역별 찾기'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WorkerIssueScreen(),
            WorkerRegionScreen(),
          ],
        ),
      ),
    );
  }
}
