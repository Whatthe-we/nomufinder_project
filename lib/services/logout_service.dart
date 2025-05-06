import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<void> handleLogout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
    print('[DEBUG] 로그아웃 완료');
    if (context.mounted) context.go('/home');
  } catch (e) {
    print('[ERROR] 로그아웃 실패: $e');
  }
}
