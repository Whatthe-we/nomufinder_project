import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
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

/// Firebase 인증 상태 스트림
final authStateProvider = StreamProvider<User?>(
      (ref) => FirebaseAuth.instance.authStateChanges(),
);

/// GoRouter 상태 갱신 Provider
final routerRefreshProvider = Provider<GoRouterRefreshStream>((ref) {
  final authStream = ref.watch(authStateProvider.stream);
  return GoRouterRefreshStream(authStream);
});