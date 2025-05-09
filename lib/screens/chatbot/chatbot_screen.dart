import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_nomufinder/widgets/common_header.dart'; // 공통 헤더

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

  /// ✅ 추가!
  Future<String> sendQueryWithContext(List<Map<String, String>> chatHistory) async {
    final newRef = _questionsRef.push();
    await newRef.set({
      'chat_history': chatHistory,
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
  final List<Map<String, String>> chatContext = []; // ✅ 문맥 누적 저장
  final TextEditingController _controller = TextEditingController();
  final ChatbotService chatbotService = ChatbotService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final firstMessage = ChatMessage(text: '안녕하세요.\n무엇을 도와드릴까요?', isUser: false);
    messages.add(firstMessage);
    chatContext.add({'role': 'assistant', 'content': firstMessage.text});
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
    });
    chatContext.add({'role': 'user', 'content': text});
    _controller.clear();

    // ✅ 자동 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    final questionId = await chatbotService.sendQueryWithContext(chatContext); // ✅ 변경

    chatbotService.listenForAnswer(
      questionId: questionId,
      onAnswer: (answer) {
        setState(() {
          messages.add(ChatMessage(text: answer, isUser: false));
        });
        chatContext.add({'role': 'assistant', 'content': answer}); // ✅ 응답도 문맥에 추가
      },
    );
  }

  Widget buildMessage(ChatMessage message) {
    final isUser = message.isUser;
    final bgColor = isUser ? const Color(0xFF5260EF) : const Color(0xFF262628);
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final avatar = isUser
        ? null
        : Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CircleAvatar(
        backgroundImage: AssetImage('assets/images/logo.png'),
        radius: 22,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) avatar!,
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
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
        backgroundColor: Colors.white,
        elevation: 1,
        title: const CommonHeader(), // 공통 헤더
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: ListView.builder(
                controller: _scrollController, // ✅ 여기 연결!
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: messages.length,
                itemBuilder: (context, index) => buildMessage(messages[index]),
              ),
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
                      filled: true,
                      fillColor: Color(0xFFF4F2F2),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide(color: Color(0xFF90CAF9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide(color: Color(0xFF0024EE), width: 2), // ✅ 포커스 시 진한 파랑
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF0024EE)),
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