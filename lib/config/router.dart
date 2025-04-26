import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_nomufinder/models/lawyer.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/input/input_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/worker/worker_screen.dart'; // 상황별/지역별 통합 탭 화면
import '../screens/lawyer_search/keyword_search_screen.dart'; // 검색 화면
import '../screens/auth/my_page_screen.dart';
import '../screens/reservation/reservation_screen.dart';
import '../screens/reservation/reservation_success_screen.dart';
import 'package:project_nomufinder/screens/reservation/my_reservations_screen.dart';
import '../screens/chatbot/chatbot_screen.dart'; // ✅ 챗봇
import 'package:project_nomufinder/screens/lawyer_search/lawyer_list_screen.dart'; // ✅ 노무사 리스트
import '../screens/favorites/favorites_screen.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final location = router.routerDelegate.currentConfiguration.uri.toString();

    final currentIndex = () {
      if (location.startsWith('/home')) return 0;
      if (location.startsWith('/search')) return 1;
      if (location.startsWith('/chatbot')) return 2;
      if (location.startsWith('/favorites')) return 3;
      if (location.startsWith('/mypage')) return 4;
      return 0;
    }();

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: Colors.grey[800],
      unselectedItemColor: Colors.grey[800],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/search');
            break;
          case 2:
            context.go('/chatbot');
            break;
          case 3:
            context.go('/favorites');
            break;
          case 4:
            context.go('/mypage');
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
    // 초기 단일 화면들 (내비게이션 바 없음)
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

    // ShellRoute 포함 화면들 (내비게이션 바 있음)
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
            child: const WorkerScreen(), // 상황별/지역별 통합 탭 화면
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
        GoRoute(
          path: '/chatbot', // ✅ 챗봇 경로 추가
          name: 'Chatbot',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ChatbotScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/mypage',
          name: 'MyPage',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const MyPageScreen(), // 마이페이지 화면
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/lawyer_list', // ✅ 노무사 리스트 경로 추가
          name: 'LawyerList',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;

            final title = extra?['title'] as String? ?? '노무사 목록';
            final category = extra?['category'] as String?;
            final lawyers = (extra?['lawyers'] as List?)?.cast<Lawyer>() ?? [];

            return CustomTransitionPage(
              key: state.pageKey,
              child: LawyerListScreen(
                title: title,
                category: category,
                lawyers: lawyers,
              ),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                  FadeTransition(opacity: animation, child: child),
            );
          },
        ),
        GoRoute(
          path: '/my-reservations',
          name: 'MyReservations',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const MyReservationsScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/favorites',
          name: 'Favorites',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const FavoritesScreen(), // ✅ 방금 만든 화면
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/reservation',
          builder: (context, state) {
            final lawyer = state.extra as Lawyer;
            return ReservationScreen(lawyer: lawyer);
          },
        ),
        GoRoute(
          path: '/reservation_success',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final dynamic dateRaw = extra?['date'];
            final date = dateRaw is DateTime ? dateRaw : DateTime.parse(dateRaw); // string일 경우 파싱
            final time = extra?['time'] as String?;
            final lawyerMap = extra?['lawyer'];

            final lawyer = lawyerMap != null ? Lawyer.fromJson(lawyerMap) : null;

            return ReservationSuccessScreen(
              date: date,
              time: time ?? '',
              lawyer: lawyer!,
            );
          },
        ),
      ],
    ),
  ],
);