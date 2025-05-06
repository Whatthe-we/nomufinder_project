import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_nomufinder/services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true; // 🔁 로그인/회원가입 전환

  // 이메일 로그인 또는 회원가입
  Future<void> _submitEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLoginMode) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      await _handlePostLogin();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? '오류 발생')),
      );
    }
  }

  // 구글 로그인
  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final auth = FirebaseAuth.instance;

      final completer = Completer<void>();
      final sub = auth.authStateChanges().listen((user) {
        if (user != null && !completer.isCompleted) {
          completer.complete();
        }
      });

      await auth.signInWithCredential(credential);
      await completer.future;
      await sub.cancel();

      await _handlePostLogin();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google 로그인 실패: $e')),
      );
    }
  }

  /// 🔁 로그인 후 분기 처리
  Future<void> _handlePostLogin() async {
    final isFirstLogin = await FirebaseService.checkAndCreateUserDocument();
    if (!mounted) return;

    if (isFirstLogin) {
      context.replace('/onboarding');;
    } else {
      final meta = await FirebaseService.getUserMeta();
      if (meta?['surveyCompleted'] == true) {
        context.replace('/home');
      } else {
        context.replace('/input');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _isLoginMode;

    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? '로그인' : '회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitEmailAuth,
              child: Text(isLogin ? '로그인' : '회원가입'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoginMode = !_isLoginMode;
                });
              },
              child: Text(
                isLogin ? '계정이 없으신가요? 회원가입' : '이미 계정이 있나요? 로그인',
              ),
            ),
            const Divider(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Google 로그인'),
              onPressed: _signInWithGoogle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}