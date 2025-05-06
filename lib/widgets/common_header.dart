import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'NOMU FINDER',
          style: TextStyle(
            color: Color(0xFF000FBA),
            fontSize: 20,
            fontWeight: FontWeight.w900, // 더 진하게
            fontStyle: FontStyle.italic,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              print('[DEBUG] 로그인 안됨 → /login 이동');
              context.go('/login?redirect=%2Fmypage');
            } else {
              context.push('/mypage');
            }
          },
          child: Row(
            children: [
              Icon(Icons.settings, color: Colors.grey[600], size: 20),
              const SizedBox(width: 4),
              Text(
                '마이페이지',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}