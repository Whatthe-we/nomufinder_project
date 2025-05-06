import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_nomufinder/services/lawyer_data_loader.dart'; // JSON 데이터 로딩 파일
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase DB 저장
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:project_nomufinder/config/router.dart';
import 'config/providers.dart';
import 'package:project_nomufinder/screens/auth/my_page_screen.dart';
import 'firebase_options.dart'; // flutterfire CLI 생성 파일
import 'package:project_nomufinder/viewmodels/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase 초기화 (중복 초기화 방지)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  // .env 환경 변수 로드
  await dotenv.load(fileName: ".env");

  // JSON 데이터 로드 (노무사 데이터 등)
  await loadLawyerData();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'NomuFinder',
      theme: ThemeData(useMaterial3: true),
      builder: (context, child) {
        return authState.when(
          data: (user) => child!,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('에러: $e')),
        );
      },
    );
  }
}