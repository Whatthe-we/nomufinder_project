import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

final FirebaseDatabase _customDb = FirebaseDatabase.instanceFor(
  app: Firebase.app(),
  databaseURL: 'https://nomufinder-default-rtdb.asia-southeast1.firebasedatabase.app',
); // ✅ Realtime DB 지역 수동 지정

class ChatbotService {
  final DatabaseReference _questionsRef = _customDb.ref('chat_questions'); // ✅ 수정
  final DatabaseReference _answersRef = _customDb.ref('chat_answers');     // ✅ 수정
  /// 질문 전송 → ID 반환
  Future<String> sendQuery(String query) async {
    final newRef = _questionsRef.push();
    await newRef.set({
      'query': query,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    return newRef.key!;
  }

  /// 질문 ID에 대한 답변 리스너
  void listenForAnswer({
    required String questionId,
    required void Function(String answer) onAnswer,
    void Function(String error)? onError,
  }) {
    final ref = _answersRef.child(questionId);
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;
      if (data.containsKey('answer')) {
        onAnswer(data['answer']);
      } else if (data.containsKey('error')) {
        onError?.call(data['error']);
      }
    });
  }
}