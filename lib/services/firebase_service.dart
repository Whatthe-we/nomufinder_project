import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodels/input_viewmodel.dart';

class FirebaseService {
  static final _firestore = FirebaseFirestore.instance;

  /// 설문 저장
  static Future<void> saveSurvey(InputState state) async {
    try {
      await _firestore.collection('survey_responses').add({
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
    } catch (e) {
      print('❌ Firestore 저장 실패: $e');
      rethrow;
    }
  }

  /// 챗봇 기록 저장
  Future<void> saveChat({
    required String userId,
    required String question,
    required String answer,
    required DateTime timestamp,
  }) async {
    await _firestore.collection('chat_logs').add({
      'userId': userId,
      'question': question,
      'answer': answer,
      'timestamp': timestamp,
    });
  }

  /// 이전 메시지 가져오기
  Future<List<Map<String, String>>> loadChatHistory(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chat_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'role': data['role'].toString(),
        'message': data['message'].toString(),
      };
    }).toList();
  }
}