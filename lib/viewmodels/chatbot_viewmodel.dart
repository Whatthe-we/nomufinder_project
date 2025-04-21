import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chatbot_service.dart';
import 'package:firebase_database/firebase_database.dart';

final chatbotViewModelProvider = StateNotifierProvider<ChatbotViewModel, void>((ref) {
  return ChatbotViewModel();
});

class ChatbotViewModel extends StateNotifier<void> {
  ChatbotViewModel() : super(null);

  final dbRef = FirebaseDatabase.instance.ref();

  Future<void> sendMessage(String message) async {
    await saveToFirebase("user", message);

    try {
      // RAG 응답 호출
      final response = await ChatbotService.getRagResponse(message);
      await saveToFirebase("bot", response);
    } catch (e) {
      await saveToFirebase("bot", "⚠️ 오류: $e");
    }
  }

  Future<void> saveToFirebase(String role, String message) async {
    if (role == "user") {
      await dbRef.child('chat_questions').push().set({
        'query': message,
        'timestamp': ServerValue.timestamp, // 서버 기준 시간
      });
    } else {
      await dbRef.child('chat_answers').push().set({
        'answer': message,
        'timestamp': ServerValue.timestamp,
      });
    }
  }
}