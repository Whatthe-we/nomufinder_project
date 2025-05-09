import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:project_nomufinder/services/firebase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _agreedToMarketing = false;
  bool _agreedToTerms = false;
  bool _agreedToPersonal = false;

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  Future<void> _submitRegistration() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 이메일 형식을 입력해 주세요.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호는 6자리 이상이어야 합니다.')),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('약관에 동의해 주세요.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseService.checkAndCreateUserDocument(
        name: _nameController.text.trim(),
        pushNotificationAgreed: _agreedToMarketing,
      );

      if (!mounted) return;
      context.replace('/onboarding');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? '회원가입 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 30.0),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo3.png',
                            height: 50,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'NOMU FINDER',
                            style: TextStyle(
                              color: Color(0xFF000FBA),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _buildInputField(_emailController, 'email@example.com', Icons.email),
                  _buildInputField(_passwordController, '비밀번호를 입력해주세요', Icons.lock, obscure: true),
                  _buildInputField(_nameController, '이름을 입력해주세요', Icons.person),
                  _buildInputField(_phoneController, '휴대폰 번호 - 없이 입력해주세요', Icons.phone),
                  const SizedBox(height: 20),

                  // 체크박스
                  CheckboxListTile(
                    value: _agreedToMarketing,
                    onChanged: (value) => setState(() => _agreedToMarketing = value!),
                    title: const Text('광고성 마케팅 수신 동의 (선택)',
                      style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w400),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    dense: true,
                    visualDensity: VisualDensity(vertical: -3),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  CheckboxListTile(
                    value: _agreedToTerms,
                    onChanged: (value) => setState(() => _agreedToTerms = value!),
                    title: const Text('서비스 이용 약관 동의 (필수)',
                      style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w400),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    dense: true,
                    visualDensity: VisualDensity(vertical: -3),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  CheckboxListTile(
                    value: _agreedToPersonal,
                    onChanged: (value) => setState(() => _agreedToPersonal = value!),
                    title: const Text('개인정보 취급 방침 동의 (필수)',
                      style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w400),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    dense: true,
                    visualDensity: VisualDensity(vertical: -3),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: ElevatedButton(
          onPressed: (_agreedToTerms && _agreedToPersonal) ? _submitRegistration : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: (_agreedToTerms && _agreedToPersonal)
                ? Colors.black
                : Colors.grey[300],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          child: const Text('동의하고 회원가입'),
        ),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller,
      String hint,
      IconData icon, {
        bool obscure = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFBDBDBD)),
          border: const UnderlineInputBorder(),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF9D9D9E), width: 1.5),
          ),
        ),
      ),
    );
  }
}