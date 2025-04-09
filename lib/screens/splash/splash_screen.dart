import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        // GoRouter로 자동 이동
        context.go('/onboarding');
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 상태바 (9:41 등)
          Positioned(
            left: 20,
            top: 14,
            child: Text(
              '9:41',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.17,
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: Container(
              width: 18,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 로고 화면
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const Text(
                  'NOMU\nFINDER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Anybody',
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -0.5,
                    color: Color(0xFF000FBA),
                    shadows: [
                      Shadow(
                        offset: Offset(0, 4),
                        blurRadius: 4,
                        color: Color(0x40000000), // 반투명 검정
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}