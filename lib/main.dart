import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/router.dart'; // GoRouter 설정
import 'config/providers.dart'; // 필요 시 사용
import 'package:project_nomufinder/services/lawyer_data_loader.dart'; // ✅ JSON 데이터 로딩 파일

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ 비동기 초기화 필요
  await loadLawyerData(); // ✅ JSON 데이터 미리 로딩

  runApp(
    const ProviderScope( // ✅ Riverpod 적용을 위한 최상위 위젯
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
    );
  }
}
