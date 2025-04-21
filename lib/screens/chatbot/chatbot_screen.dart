import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../viewmodels/chatbot_viewmodel.dart';

final dbRef = FirebaseDatabase.instance.ref();

class ChatbotScreen extends ConsumerWidget {
  final TextEditingController _controller = TextEditingController();

  ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbRef = FirebaseDatabase.instance.ref().child('chat_answers').orderByChild('timestamp');

    return Scaffold(
      appBar: AppBar(title: const Text("노무 챗봇")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: dbRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("대화 내역이 없습니다."));
                }

                final data = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map,
                );

                final messages = data.entries
                    .map((e) => Map<String, dynamic>.from(e.value))
                    .toList()
                  ..sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUser = message['role'] == 'user';

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(message['message']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: "노무 고민을 입력하세요"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      ref.read(chatbotViewModelProvider.notifier).sendMessage(text);
                      _controller.clear();
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}