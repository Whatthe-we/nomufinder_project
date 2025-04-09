import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/router.dart'; // GoRouter 설정
import 'config/providers.dart'; // ProviderScope 설정 시 필요한 경우

void main() {
  runApp(
    const ProviderScope( // Riverpod 적용을 위한 최상위 위젯
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router, // GoRouter 사용
      title: 'NomuFinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
    );
  }
}
