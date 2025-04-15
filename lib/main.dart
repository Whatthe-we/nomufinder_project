import 'dart:io'; // 👈 for Platform
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase 추가
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/router.dart'; // GoRouter 설정
import 'config/providers.dart'; // ProviderScope 설정 시 필요한 경우
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 비동기 초기화
  await Firebase.initializeApp();            // Firebase 초기화

  // 에뮬레이터 vs 실제 디바이스 구분
  final isEmulator = await _isRunningOnEmulator();

  // 환경파일 자동 로드
  await dotenv.load(                         // flutter_dotenv 초기화
      fileName: isEmulator ? '.env.dev' : '.env.prod');

  runApp(
    const ProviderScope( // Riverpod 적용을 위한 최상위 위젯
      child: MyApp(),
    ),
  );
}

// 에뮬레이터 판단
Future<bool> _isRunningOnEmulator() async {
  if (Platform.isAndroid) {
    const emulatorIndicators = ['google_sdk', 'sdk_gphone', 'emulator', 'sdk'];
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

// 로컬 IP 가져오기 (192.168.XXX)
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

  return '127.0.0.1'; // fallback
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
    );
  }
}