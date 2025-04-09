import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/input/input_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart'; // Onboarding 화면 import

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
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
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'Onboarding',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OnboardingScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
  ],
);