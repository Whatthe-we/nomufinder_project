import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/input/input_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/worker/worker_screen.dart';
import '../screens/lawyer_search/keyword_search_screen.dart';
import '../screens/auth/my_page_screen.dart';
import '../screens/reservation/reservation_screen.dart';
import '../screens/reservation/reservation_success_screen.dart';
import '../screens/reservation/my_reservations_screen.dart';
import '../screens/chatbot/chatbot_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/lawyer_search/lawyer_list_screen.dart';
import '../screens/reviews/review_create_screen.dart';
import '../screens/reviews/my_reviews_screen.dart';

import '../screens/auth/login_screen.dart';
import '../services/firebase_service.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/edit_profile_screen.dart'; // ✅ 추가
import '../screens/favorites/post_detail_screen.dart'; // PostDetailScreen import
import '../screens/favorites/post_list_provider.dart'; // postListProvider import
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ref 사용을 위한 import

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index, BuildContext context) {
    setState(() {
      _selectedIndex = index;
    });
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
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey[800],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      onTap: (index) => _onItemTapped(index, context),
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

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      // ✅ FirebaseAuth가 main()에서 초기화된 후 호출됨
      final user = FirebaseAuth.instance.currentUser;

      const publicPaths = ['/login', '/register', '/onboarding'];
      if (user == null) {
        if (!publicPaths.contains(state.fullPath)) {
          return '/login';
        } else {
          return null;
        }
      }

      final userMeta = await FirebaseService.getUserMeta();

      if (userMeta == null) return '/onboarding';

      final isFirstLogin = userMeta['isFirstLogin'] ?? true;
      final surveyCompleted = userMeta['surveyCompleted'] ?? false;

      if (isFirstLogin && state.fullPath != '/onboarding') {
        return '/onboarding';
      }

      if (!surveyCompleted &&
          state.fullPath != '/input' &&
          state.fullPath != '/onboarding') {
        return '/input';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'Splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'Login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'Register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/input',
        name: 'Input',
        pageBuilder: (context, state) =>
            CustomTransitionPage(
              key: state.pageKey,
              child: const InputScreen(),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (context, animation, secondaryAnimation,
                  child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'Onboarding',
        pageBuilder: (context, state) =>
            CustomTransitionPage(
              key: state.pageKey,
              child: const OnboardingScreen(),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (context, animation, secondaryAnimation,
                  child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
      ),
      GoRoute(
        path: '/lawyer_list',
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
            ),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation,
                child) =>
                FadeTransition(opacity: animation, child: child),
          );
        },
      ),
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
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: const HomeScreen(),
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionsBuilder: (context, animation, secondaryAnimation,
                      child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
          ),
          GoRoute(
            path: '/worker',
            name: 'Worker',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: const WorkerScreen(),
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionsBuilder: (context, animation, secondaryAnimation,
                      child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
          ),
          GoRoute(
            path: '/search',
            name: 'Search',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: const KeywordSearchScreen(),
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionsBuilder: (context, animation, secondaryAnimation,
                      child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
          ),
          GoRoute(
            path: '/chatbot',
            name: 'Chatbot',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: const ChatbotScreen(),
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionsBuilder: (context, animation, secondaryAnimation,
                      child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
          ),
          GoRoute(
            path: '/favorites',
            name: 'Favorites',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: const FavoritesScreen(),
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionsBuilder: (context, animation, secondaryAnimation,
                      child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
          ),
          GoRoute(
            path: '/mypage',
            name: 'MyPage',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: const MyPageScreen(),
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionsBuilder: (context, animation, secondaryAnimation,
                      child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
          ),
          GoRoute(
            path: '/my-reservations',
            name: 'MyReservations',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: const MyReservationsScreen(),
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionsBuilder: (context, animation, secondaryAnimation,
                      child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
          ),
          GoRoute(
            path: '/my-reviews',
            name: 'MyReviews',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: const MyReviewsScreen(),
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionsBuilder: (context, animation, secondaryAnimation,
                      child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
          ),
        ],
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'EditProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/reservation',
        builder: (context, state) {
          final lawyer = state.extra as Lawyer;
          return ReservationScreen(lawyer: lawyer);
        },
      ),
      GoRoute(
        path: '/review-create',
        builder: (context, state) {
          final lawyer = state.extra as Lawyer;
          return ReviewCreateScreen(lawyer: lawyer);
        },
      ),
      GoRoute(
        path: '/reservation_success',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final dynamic dateRaw = extra?['date'];
          final date = dateRaw is DateTime ? dateRaw : DateTime.parse(dateRaw);
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
      // router.dart

      GoRoute(
        path: '/post/:postId', // :postId는 동적 파라미터
        name: 'PostDetail',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          // postListProvider에서 해당 ID의 post를 찾아서 PostDetailScreen에 전달
          return Consumer(
            builder: (context, ref, child) {
              final post = ref.read(postListProvider).firstWhere((p) =>
              p.id == postId);
              return PostDetailScreen(post: post);
            },
          );
        },
      ),
    ],
  );
}