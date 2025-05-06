import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_service.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 2));
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (context.mounted) context.go('/login');
        return;
      }

      final userMeta = await FirebaseService.getUserMeta();
      final isFirstLogin = userMeta?['isFirstLogin'] ?? true;
      final surveyCompleted = userMeta?['surveyCompleted'] ?? false;

      if (context.mounted) {
        if (isFirstLogin) {
          context.go('/onboarding');
        } else if (!surveyCompleted) {
          context.go('/input');
        } else {
          context.go('/home');
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage('assets/images/logo.png'),
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24),
            Text(
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
                    color: Color(0x40000000),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}