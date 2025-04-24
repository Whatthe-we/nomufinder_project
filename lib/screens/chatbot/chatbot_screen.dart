import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/chatbot_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      final isFirstVisit = prefs.getBool('chatbot_first_visit') ?? true;

      if (isFirstVisit) {
        await prefs.setBool('chatbot_first_visit', false);
      } else {
        await _askToLoadPreviousChat();
      }
    });
  }

  Future<void> _askToLoadPreviousChat() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("이전 대화를 불러올까요?"),
        content: const Text("이전에 했던 대화를 이어서 할 수 있어요."),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(chatbotMessagesProvider.notifier).clearMessages();
              Navigator.of(context).pop(false);
            },
            child: const Text("새로 시작"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("불러오기"),
          ),
        ],
      ),
    );

    if (result == true) {
      final messages = await ref.read(firebaseServiceProvider).loadChatHistory('temp-user');
      ref.read(chatbotMessagesProvider.notifier).loadPreviousMessages(messages);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatbotMessagesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI 챗봇 상담')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['message'] ?? '', style: const TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: '고민을 입력하세요'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _controller.text.trim();
                    if (message.isNotEmpty) {
                      ref.read(chatbotMessagesProvider.notifier).sendMessage(message);
                      _controller.clear();
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}