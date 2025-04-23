import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_nomufinder/services/lawyer_data_loader.dart'; // ✅ JSON 데이터 로딩 파일
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_info_plus/device_info_plus.dart'; // 추가
import 'package:firebase_core/firebase_core.dart'; // ✅ Firebase DB 저장
import 'dart:io';
import 'config/router.dart';
import 'config/providers.dart';
import 'package:project_nomufinder/screens/auth/my_page_screen.dart';
import 'firebase_options.dart'; // flutterfire CLI 생성 파일

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("⚠️ Firebase 초기화 무시됨: $e");
  }

  // JSON 데이터 로드
  await loadLawyerData();

  // 환경변수 로드
  final isEmulator = await _isRunningOnEmulator();
  await dotenv.load(fileName: '.env.template');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'NomuFinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

// 에뮬레이터 판별 함수
Future<bool> _isRunningOnEmulator() async {
  if (Platform.isAndroid) {
    const emulatorIndicators = ['google_sdk', 'sdk_gphone'];
    try {
      final buildProp = await File('/system/build.prop').readAsString();
      return emulatorIndicators.any((e) => buildProp.contains(e));
    } catch (_) {
      return false;
    }
  } else if (Platform.isIOS) {
    final deviceInfo = DeviceInfoPlugin();
    final iosInfo = await deviceInfo.iosInfo;
    return !iosInfo.isPhysicalDevice;
  }
  return false;
}

// 로컬 IP 가져오기
Future<String> _getHostIP() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
    includeLoopback: false,
  );

  for (final interface in interfaces) {
    for (final addr in interface.addresses) {
      if (!addr.isLoopback && addr.address.startsWith('192.')) {
        return addr.address;
      }
    }
  }

  return '127.0.0.1';
}