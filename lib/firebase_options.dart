import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
    // iOS는 아직 구성 안 했으므로 차단
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS 설정은 아직 구성되지 않았습니다.');
      default:
        throw UnsupportedError('이 플랫폼은 지원되지 않습니다.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBs2zhOvrT0B3MfYdJ3HXlV3OjsDzyNUk8",
    appId: "1:1058085475204:web:574010431cf5f82d2583d1",
    messagingSenderId: "1058085475204",
    projectId: "nomufinder",
    databaseURL: "https://nomufinder-default-rtdb.asia-southeast1.firebasedatabase.app",
    storageBucket: "nomufinder.firebasestorage.app",
  );
}