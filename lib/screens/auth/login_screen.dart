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
  bool _isLoginMode = true; // 로그인/회원가입 전환
  bool _keepSignedIn = false; // 로그인 상태 유지 체크

  // 이메일 로그인 또는 회원가입
  Future<void> _submitEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // ✅ 아무것도 입력하지 않았을 때 경고
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 모두 입력해 주세요.')),
      );
      return;
    }

    // ✅ 이메일 형식 검사
    final isValidEmail = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    if (!isValidEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 이메일 형식을 입력해 주세요.')),
      );
      return;
    }

    // ✅ 비밀번호 길이 검사
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호는 6자리 이상이어야 합니다.')),
      );
      return;
    }

    try {
      if (_isLoginMode) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
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

  /// 로그인 후 분기 처리
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 400,
          height: 1012,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Stack(
            children: [
              // 상단 탭 (로그인 / 노무사)
              Positioned(
                top: 126,
                left: 40,
                child: Container(
                  width: 160,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Color(0x3F000000), blurRadius: 1)],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '로그인',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF404040)),
                  ),
                ),
              ),
              Positioned(
                top: 126,
                left: 200,
                child: Container(
                  width: 160,
                  height: 40,
                  decoration: const BoxDecoration(color: Color(0xFFD9D9D9)),
                  alignment: Alignment.center,
                  child: const Text(
                    '노무사로 로그인',
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Color(0xFF494949)),
                  ),
                ),
              ),

              // 이메일 입력
              Positioned(
                left: 32,
                top: 200,
                right: 32,
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '아이디 입력',
                    isDense: true,
                    contentPadding: EdgeInsets.only(bottom: 4),
                    labelStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 15),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFDADCE0)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF9D9D9E), width: 1.5),
                    ),
                  ),
                ),
              ),

              // 비밀번호 입력
              Positioned(
                left: 32,
                top: 260,
                right: 32,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호 입력',
                    isDense: true,
                    contentPadding: EdgeInsets.only(bottom: 4),
                    labelStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 15),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFDADCE0)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF9D9D9E), width: 1.5),
                    ),
                  ),
                ),
              ),

              // 로그인 상태 유지 / 아이디 비번 찾기
              Positioned(
                left: 42,
                top: 330,
                right: 42,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 체크박스 + 로그인 상태 유지
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _keepSignedIn,
                            onChanged: (value) {
                              setState(() {
                                _keepSignedIn = value!;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(color: Colors.black38),
                            activeColor: Color(0xFFBDBDBD),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          '로그인 상태 유지',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF494949),
                          ),
                        ),
                      ],
                    ),
                    // 아이디/비밀번호 찾기
                    const Text(
                      '아이디/비밀번호 찾기',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF494949),
                      ),
                    ),
                  ],
                ),
              ),

              // 로그인 버튼
              Positioned(
                left: 32,
                top: 395,
                right: 32,
                child: ElevatedButton(
                  onPressed: _submitEmailAuth,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                    backgroundColor: Colors.white,
                    shadowColor: const Color(0x33000000),
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                      side: const BorderSide(color: Color(0xFFDADCE0)), // 테두리 색
                    ),
                  ),
                  child: Text(
                    _isLoginMode ? '로그인' : '회원가입',
                    style: const TextStyle(color: Color(0xFF3C4043), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              // 회원가입 텍스트 버튼
              Positioned(
                left: 0,
                right: 0,
                top: 570,
                child: GestureDetector(
                  onTap: () {
                    context.push('/register'); // ✅ 회원가입 화면으로 이동
                  },
                  child: const Center(
                    child: Text(
                      '회원가입',
                      style: TextStyle(color: Color(0xFF3C4043), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),

              // Google 로그인
              Positioned(
                left: 32,
                top: 450,
                right: 32,
                child: ElevatedButton(
                  onPressed: _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shadowColor: const Color(0x33000000),
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                      side: const BorderSide(color: Color(0xFFDADCE0)), // 테두리 색
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google_logo.png',
                        height: 20,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Google로 로그인',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF3C4043),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}