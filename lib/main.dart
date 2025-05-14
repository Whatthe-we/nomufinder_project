import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_nomufinder/services/lawyer_data_loader.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:project_nomufinder/config/router.dart';
import 'firebase_options.dart';
import 'package:project_nomufinder/viewmodels/auth_provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('💬 백그라운드 메시지 수신: ${message.messageId}');
}
late final GoRouter appRouter;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase 무조건 초기화
  await firebase_core.Firebase.initializeApp();
  print("✅ Firebase 초기화 완료");

  // ✅ .env 환경 변수 로드
  await dotenv.load(fileName: ".env");

  // ✅ JSON 데이터 로드 (노무사 데이터 등)
  await loadLawyerData();

  // ✅ FCM 설정
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _setupFCM();

  // ✅ GoRouter 초기화
  appRouter = createRouter();

  runApp(ProviderScope(child: MyApp(router: appRouter)));
}

Future<void> _setupFCM() async {
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('🛠️ 알림 권한: ${settings.authorizationStatus}');

  final token = await messaging.getToken();
  print('🔥 FCM 토큰: $token');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('💬 포그라운드 메시지 수신!');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print('💬 알림 내용: ${message.notification}');
    }
  });
}

class MyApp extends ConsumerWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider); // ✅ 여기는 유지

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