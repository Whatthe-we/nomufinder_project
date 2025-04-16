import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/input/input_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/worker/worker_screen.dart';
import '../screens/lawyer_search/keyword_search_screen.dart'; // 🔍 검색 화면 추가

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.grey[800],
      unselectedItemColor: Colors.grey[800],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      currentIndex: 0, // 상태관리 적용 안된 단순 예시
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/search'); // ✅ 검색 화면으로 이동
            break;
          case 2:
          // context.go('/chatbot');
            break;
          case 3:
          // context.go('/favorites');
            break;
          case 4:
          // context.go('/mypage');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: '챗봇'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '내 관심글'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
      ],
    );
  }
}

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // ✅ 초기 단일 화면들 (내비게이션 바 없음)
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

    // ✅ ShellRoute 포함 화면들 (내비게이션 바 있음)
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
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/worker',
          name: 'Worker',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const WorkerScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/search',
          name: 'KeywordSearch',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const KeywordSearchScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
      ],
    ),
  ],
);