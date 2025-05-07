import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_nomufinder/services/logout_service.dart';
import 'package:project_nomufinder/services/firebase_lawyer_uploader.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

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
          // 1. 프로필 섹션 추가
          _profileSection(context),

          _sectionTitle("내 활동"),
          _linkTile("🔥 노무사 Firestore 재업로드", Icons.cloud_upload, () async {
            await FirebaseLawyerUploader.uploadLawyersFromJson();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ 노무사 업로드 완료")),
            );
          }),
          _linkTile("관심노무사", Icons.favorite_border, () {
            // TODO: 관심노무사 이동
          }),
          _linkTile("최근 본 게시글", Icons.history, () {
            // TODO: 최근 게시글 이동
          }),
          _linkTile("예약내역", Icons.calendar_today, () {
            context.push('/my-reservations');
          }),

          _linkTile("내 후기", Icons.rate_review, () {
            context.push('/my-reviews'); // ✅ 후기 목록 화면으로 이동
          }),

          const Divider(height: 32),

          // 2. 알림 섹션 확장
          _sectionTitle("알림"),
          SwitchListTile(
            value: true,
            onChanged: (val) {
              // TODO: 알림 설정
            },
            title: const Text("알림"),
            activeColor: Colors.blue,
            secondary: Icon(Icons.notifications_active),
          ),
          SwitchListTile(
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (val) {
              // TODO: 테마 변경 (상태관리 도구 연결 필요)
            },
            title: const Text("다크 모드"),
            secondary: Icon(Icons.dark_mode),
          ),

          const Divider(height: 32),

          // 3. 설정 섹션 확장
          _sectionTitle("설정"),
          _linkTile("내 정보 수정", Icons.person, () {
            // TODO: 내 정보 수정
          }),
          _linkTile("언어 변경 (Language)", Icons.language, () {
            // TODO: 언어 변경
          }),
          ListTile(
            title: Text("캐시 데이터 삭제"),
            leading: Icon(Icons.cleaning_services, color: Colors.blue),
            onTap: () {
              // TODO: 캐시 삭제 처리
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("캐시가 삭제되었습니다.")),
              );
            },
          ),
          ListTile(
            title: const Text("앱 버전"),
            subtitle: const Text("1.0.0"),
            leading: const Icon(Icons.info_outline, color: Colors.blue),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationVersion: "1.0.0",
                applicationName: "노무사 앱",
                applicationLegalese: "© 2025 YourCompany",
              );
            },
          ),
          ListTile(
            title: const Text("회원 탈퇴", style: TextStyle(color: Colors.red)),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("회원 탈퇴"),
                  content: const Text("정말로 탈퇴하시겠습니까?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("취소"),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: 회원 탈퇴 처리
                        Navigator.pop(ctx);
                      },
                      child: const Text("탈퇴", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 32),

          // 4. 고객지원 섹션 확장
          _sectionTitle("고객지원"),
          _linkTile("공지사항", Icons.campaign, () {
            // TODO: 공지사항 페이지 이동
          }),
          _linkTile("이벤트", Icons.celebration, () {
            // TODO: 이벤트 페이지 이동
          }),
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

          // 5. 로그아웃 확인 다이얼로그 추가
          Center(
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("로그아웃"),
                    content: const Text("정말 로그아웃 하시겠습니까?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("취소"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);  // 다이얼로그 닫기
                          handleLogout(context); // 로그아웃 실행
                        },
                        child: const Text("로그아웃"),
                      ),
                    ],
                  ),
                );
              },
              child: const Text("로그아웃", style: TextStyle(color: Colors.grey)),
            ),
          )
        ],
      ),
    );
  }

  // ✅ 프로필 섹션 위젯
  Widget _profileSection(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user?.photoURL != null
              ? NetworkImage(user!.photoURL!)
              : const AssetImage('assets/images/default_user.png') as ImageProvider,
          radius: 28,
        ),
        title: Text(
          user?.displayName ?? '사용자',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user?.email ?? '이메일 없음'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // TODO: 프로필 수정 이동
          },
        ),
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
