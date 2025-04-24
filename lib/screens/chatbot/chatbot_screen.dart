import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

final FirebaseDatabase _customDb = FirebaseDatabase.instanceFor(
  app: Firebase.app(),
  databaseURL: 'https://nomufinder-default-rtdb.asia-southeast1.firebasedatabase.app',
);

class ChatbotService {
  final DatabaseReference _questionsRef = _customDb.ref('chat_questions');
  final DatabaseReference _answersRef = _customDb.ref('chat_answers');

  Future<String> sendQuery(String query) async {
    final newRef = _questionsRef.push();
    await newRef.set({
      'query': query,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    return newRef.key!;
  }

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

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ChatbotService chatbotService = ChatbotService();

  @override
  void initState() {
    super.initState();
    messages.add(ChatMessage(text: '안녕하세요.\n무엇을 도와드릴까요?', isUser: false));
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
    });
    _controller.clear();

    final questionId = await chatbotService.sendQuery(text);
    chatbotService.listenForAnswer(
      questionId: questionId,
      onAnswer: (answer) {
        setState(() {
          messages.add(ChatMessage(text: answer, isUser: false));
        });
      },
    );
  }

  Widget buildMessage(ChatMessage message) {
    final isUser = message.isUser;
    final bgColor = isUser ? const Color(0xFF5260EF) : const Color(0xFF262628);
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final avatar = isUser ? null : Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CircleAvatar(
        backgroundImage: AssetImage('assets/images/logo.png'),
        radius: 22,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) avatar!,
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'OpenSans',
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('노무무 챗봇'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) => buildMessage(messages[index]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '고민을 입력하세요',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF5260EF)),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}