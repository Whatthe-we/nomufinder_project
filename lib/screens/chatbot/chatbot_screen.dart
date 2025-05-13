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
    required void Function(String answer, String? followup) onAnswer,
    void Function(String error)? onError,
  }) {
    final ref = _answersRef.child(questionId);
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;
      if (data.containsKey('answer')) {
        final answer = data['answer'] ?? '';
        final followup = data['followup_question'] ?? '';
        onAnswer(answer, followup);  // ✅ followup 전달
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
  bool isTyping = false;
  String? _lastQuestionId;
  bool hasAskedFollowup = false; // ✅ 후속질문 1회 제한용

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
      isTyping = true;
    });
    // ✅ 유저 입력 직후 스크롤 아래로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    chatContext.add({'role': 'user', 'content': text});

    // ✅ 최근 6개만 유지
    const int MAX_HISTORY = 6;
    if (chatContext.length > MAX_HISTORY) {
      chatContext.removeRange(0, chatContext.length - MAX_HISTORY);
    }
    _controller.clear();

    // ✅ 이곳에 로그 추가!
    print("🔥 chatContext 현재 상태:");
    for (var item in chatContext) {
      print("${item['role']}: ${item['content']}");
    }

    _lastQuestionId = await chatbotService.sendQueryWithContext(chatContext); // ✅ 여기에 저장

    chatbotService.listenForAnswer(
      questionId: _lastQuestionId!,
      onAnswer: (answer, followup) {
        setState(() {
          isTyping = false;
          // ✅ 후속질문이 있고, 아직 후속질문을 한 적이 없다면
          if (!hasAskedFollowup && followup != null && followup.isNotEmpty) {
            messages.add(ChatMessage(text: followup, isUser: false));
            chatContext.add({'role': 'assistant', 'content': followup});
            hasAskedFollowup = true; // ✅ 플래그 업데이트
          } else {
            // ✅ 후속질문이 없거나 이미 후속질문을 한 경우 → 일반 응답 출력
            messages.add(ChatMessage(text: answer, isUser: false));
            chatContext.add({'role': 'assistant', 'content': answer});
          }
        });
        // ✅ 답변 출력 이후 자동 스크롤
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      },
    );
  }

  @override
  void dispose() {
    // ✅ 대화 종료 시 Firebase 기록 삭제
    if (_lastQuestionId != null) {
      _customDb.ref('chat_questions/$_lastQuestionId').remove();
      _customDb.ref('chat_answers/$_lastQuestionId').remove();
    }
    // ✅ 컨트롤러 정리 (메모리 누수 방지)
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget buildMessage(ChatMessage message) {
    final isUser = message.isUser;
    final bgColor = isUser ? const Color(0xFF5260EF) : const Color(0xFF262628);
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

  Widget buildTypingMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.png'),
              radius: 22,
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF262628),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: const TypingIndicator(),
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
        title: const CommonHeader(),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < messages.length) {
                    return buildMessage(messages[index]);
                  } else {
                    return buildTypingMessage();
                  }
                },
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
                        borderSide: BorderSide(color: Color(0xFF0024EE), width: 2),
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

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: false);

    _dotAnimation = StepTween(begin: 1, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _dotAnimation,
        builder: (context, child) {
          final count = _dotAnimation.value;
          final dots = '.' * count;
          return Text(
            dots.padRight(4),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          );
        },
      ),
    );
  }
}