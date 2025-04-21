import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("내 활동"),
          _linkTile("관심노무사", Icons.favorite_border, () {
            // TODO: 관심노무사 이동
          }),
          _linkTile("최근 본 게시글", Icons.history, () {
            // TODO: 최근 게시글 이동
          }),
          _linkTile("예약내역", Icons.calendar_today, () {
            context.push('/my-reservations');
          }),
          _linkTile("후기 작성", Icons.rate_review, () {
            // TODO: 후기 작성 이동
          }),

          const Divider(height: 32),

          _sectionTitle("알림"),
          SwitchListTile(
            value: true,
            onChanged: (val) {
              // TODO: 알림 설정
            },
            title: const Text("알림"),
            activeColor: Colors.blue,
          ),

          const Divider(height: 32),

          _sectionTitle("설정"),
          _linkTile("내 정보 수정", Icons.person, () {
            // TODO: 내 정보 수정
          }),
          _linkTile("언어 변경 (Language)", Icons.language, () {
            // TODO: 언어 변경
          }),

          const Divider(height: 32),

          _sectionTitle("고객지원"),
          _linkTile("고객센터", Icons.support_agent, () {
            // TODO: 고객센터
          }),
          _linkTile("의견 남기기", Icons.feedback, () {
            // TODO: 피드백
          }),
          _linkTile("약관 및 정책", Icons.description, () {
            // TODO: 약관 보기
          }),

          const SizedBox(height: 30),
          Center(
            child: TextButton(
              onPressed: () {
                // TODO: 로그아웃 기능
              },
              child: const Text("로그아웃", style: TextStyle(color: Colors.grey)),
            ),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _linkTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: onTap,
    );
  }
}