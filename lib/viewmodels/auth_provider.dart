import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'dart:async';

// ✅ GoRouter 리프레시를 위한 리스너
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ✅ Firebase 초기화 이후 auth 상태 감지
final authStateProvider = StreamProvider<User?>((ref) async* {
  await firebase_core.Firebase.initializeApp(); // ✅ 이렇게 수정
  yield* FirebaseAuth.instance.authStateChanges();
});

// ✅ GoRouter 리프레시 용
final routerRefreshProvider = Provider<GoRouterRefreshStream>((ref) {
  final authStream = ref.watch(authStateProvider.stream);
  return GoRouterRefreshStream(authStream);
});