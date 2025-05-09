import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/input_viewmodel.dart';

class FirebaseService {
  static final _firestore = FirebaseFirestore.instance;

  /// 최초 로그인 시 사용자 문서 생성
  static Future<bool> checkAndCreateUserDocument({
    String? name,
    bool pushNotificationAgreed = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final docRef = _firestore.collection('users').doc(user.uid).collection(
        'meta').doc('profile');
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'name': name ?? '',
        'pushNotificationAgreed': pushNotificationAgreed,
        'isFirstLogin': true,
        'surveyCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true; // 최초 로그인
    }
    return false; // 기존 사용자
  }

  /// 온보딩 완료 처리
  static Future<void> updateIsFirstLoginFalse() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('meta')
        .doc('profile')
        .set({
      'isFirstLogin': false,
    }, SetOptions(merge: true));
  }

  static Future<void> updateIsFirstLoginAndSurveyCompleted() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('meta')
        .doc('profile')
        .set({
      'isFirstLogin': false,
      'surveyCompleted': true,
    }, SetOptions(merge: true));
  }

  /// 사용자 프로필 정보 가져오기
  static Future<Map<String, dynamic>?> getUserMeta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('meta')
        .doc('profile')
        .get();

    return snapshot.data();
  }

  /// 설문 응답 저장 + 상태 갱신
  static Future<void> saveSurvey(InputState state) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // 서브컬렉션에 설문 저장
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('survey_responses')
        .add({
      'gender': state.gender,
      'age': state.age,
      'employment': state.employment,
      'industry': state.industry,
      'companySize': state.companySize,
      'purpose': state.purpose,
      'selectedIssues': state.selectedIssues,
      'infoNeeds': state.infoNeeds,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 상태 갱신
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('meta')
        .doc('profile')
        .set({
      'surveyCompleted': true,
      'isFirstLogin': false,
    }, SetOptions(merge: true));
  }

  /// 챗봇 기록 저장
  Future<void> saveChat({
    required String userId,  // 🔄 userId 매개변수 추가
    required String question,
    required String answer,
    required DateTime timestamp,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).collection('chat_logs').add({
      'question': question,
      'answer': answer,
      'timestamp': timestamp,
    });
  }

  /// 챗봇 기록 불러오기
  Future<List<Map<String, String>>> loadChatHistory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('chat_logs')
        .orderBy('timestamp')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'question': data['question']?.toString() ?? '',
        'answer': data['answer']?.toString() ?? '',
      };
    }).toList();
  }
}