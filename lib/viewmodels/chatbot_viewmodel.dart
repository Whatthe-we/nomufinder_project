import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chatbot_service.dart';
import '../services/firebase_service.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());
final chatbotServiceProvider = Provider((ref) => ChatbotService());

final chatbotMessagesProvider =
StateNotifierProvider<ChatbotViewModel, List<Map<String, String>>>(
        (ref) => ChatbotViewModel(ref));

class ChatbotViewModel extends StateNotifier<List<Map<String, String>>> {
  final Ref ref;

  ChatbotViewModel(this.ref) : super([]);

  /// 채팅창 초기화
  void clearMessages() {
    state = [];
  }

  /// 이전 메시지 불러오기
  void loadPreviousMessages(List<Map<String, String>> previous) {
    state = previous;
  }

  Future<void> sendMessage(String message) async {
    state = [...state, {'role': 'user', 'message': message}];

    final service = ref.read(chatbotServiceProvider);
    final questionId = await service.sendQuery(message);

    state = [...state, {'role': 'bot', 'message': '답변을 생성 중입니다...'}];

    service.listenForAnswer(
      questionId: questionId,
      onAnswer: (answer) {
        state = [
          ...state.where((m) => m['message'] != '답변을 생성 중입니다...'),
          {'role': 'bot', 'message': answer},
        ];
        ref.read(firebaseServiceProvider).saveChat(
          userId: 'temp-user',
          question: message,
          answer: answer,
          timestamp: DateTime.now(),
        );
      },
      onError: (error) {
        state = [
          ...state.where((m) => m['message'] != '답변을 생성 중입니다...'),
          {'role': 'bot', 'message': '⚠️ 오류: $error'},
        ];
      },
    );
  }
}