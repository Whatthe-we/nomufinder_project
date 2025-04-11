import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/input/input_screen.dart';
import '../screens/home/home_screen.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // 모든 아이템을 균일한 색상으로 보여주기 위해 fixed로 설정
      type: BottomNavigationBarType.fixed,

      // 선택된 아이콘/레이블 색상
      selectedItemColor: Colors.grey[800],

      // 선택되지 않은 아이콘/레이블 색상
      unselectedItemColor: Colors.grey[800],

      // 선택된, 선택되지 않은 라벨 스타일 (선택 사항)
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
      ),

      currentIndex: 0, // 실제로는 상태에 따라 관리
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
          // 예시: context.go('/search');
            break;
          case 2:
          // 예시: context.go('/chatbot');
            break;
          case 3:
          // 예시: context.go('/favorites');
            break;
          case 4:
          // 예시: context.go('/mypage');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '검색',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: '챗봇',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: '내 관심글',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '마이페이지',
        ),
      ],
    );
  }
}

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // 내비게이션 바 없이 보여줄 화면들
    GoRoute(
      path: '/splash',
      name: 'Splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/input',
      name: 'Input',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const InputScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'Onboarding',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OnboardingScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    // 내비게이션 바가 적용될 화면들을 ShellRoute로 묶음
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: const MyBottomNavigationBar(),
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'Home',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
      ],
    ),
  ],
);
