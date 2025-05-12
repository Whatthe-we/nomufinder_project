import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_nomufinder/widgets/common_header.dart'; // 공통 헤더

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isFollowUp; // ✅ 추가

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isFollowUp = false,
  });
}

bool isInFollowupFlow = false;
String? currentFollowupContext = null;
List<String> pendingFollowups = [];  // 후속 질문 리스트 저장
int followupIndex = 0;               // 현재 몇 번째 후속 질문인지

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
    required void Function(Map<String, dynamic> answerJson) onAnswer,
    void Function(String error)? onError,
  }) {
    final ref = _answersRef.child(questionId);
    ref.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;

      final mapData = Map<String, dynamic>.from(data as Map);

      // ✅ 핵심: content + mode 기반 응답도 허용
      if (mapData.containsKey('content') && mapData.containsKey('mode')) {
        print("✅ Firebase 응답 수신: $mapData");
        onAnswer(mapData);
      } else if (mapData.containsKey('answer')) {
        // 이전 구조 호환
        onAnswer(mapData);
      } else if (mapData.containsKey('error')) {
        onError?.call(mapData['error']);
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

  @override
  void initState() {
    super.initState();
    final firstMessage = ChatMessage(text: '안녕하세요.\n무엇을 도와드릴까요?', isUser: false);
    messages.add(firstMessage);
    chatContext.add({'role': 'assistant', 'content': firstMessage.text});
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (handleFollowupFlow()) return;

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
      isTyping = true;
    });

    // ✅ 최근 6개만 유지
    const int MAX_HISTORY = 6;
    if (chatContext.length > MAX_HISTORY) {
      chatContext.removeRange(0, chatContext.length - MAX_HISTORY);
    }

    _controller.clear();

    // ✅ 최초 또는 최종 답변 요청
    _lastQuestionId = await chatbotService.sendQueryWithContext(chatContext);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    chatbotService.listenForAnswer(
      questionId: _lastQuestionId!,
      onAnswer: (answerJson) {
        final mode = answerJson['mode'];
        final content = answerJson['content'];
        if (content == null || content.toString().trim().isEmpty) {
          print('⚠️ content가 비어 있습니다. answerJson: $answerJson');
          return;
        }
        setState(() => isTyping = false);

        if (mode == 'followup' && content is List) {
          isInFollowupFlow = true;
          followupIndex = 0;
          pendingFollowups = List<String>.from(content.take(1));
          showNextFollowUp();
          return;
        }

        if (mode == 'answer') {
          final answerText = content is String ? content : content.toString();
          if (answerText.trim().isEmpty) {
            print('⚠️ GPT 답변이 비어 있음: $answerText');
            return;
          }
          setState(() {
            messages.add(ChatMessage(text: answerText, isUser: false));
          });
          chatContext.add({'role': 'assistant', 'content': answerText});
          isInFollowupFlow = false;
          followupIndex = 0;
          pendingFollowups.clear();
        }
      },
    );
  }

  // ✅ 여기가 핵심: sendMessage 바깥에 있어야 함!
  bool handleFollowupFlow() {
    if (isInFollowupFlow && followupIndex < pendingFollowups.length) {
      final nextFollowup = pendingFollowups[followupIndex];
      setState(() {
        isTyping = false;
        messages.add(ChatMessage(text: nextFollowup, isUser: false, isFollowUp: true));
      });
      chatContext.add({'role': 'assistant', 'content': nextFollowup});
      followupIndex++;

      if (followupIndex >= pendingFollowups.length) {
        isInFollowupFlow = false;
      }
      return true;
    }
    return false;
  }

  void scrollToBottomRepeatedly({int times = 3, int delayMs = 100}) {
    for (int i = 0; i < times; i++) {
      Future.delayed(Duration(milliseconds: delayMs * i), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void showNextFollowUp() {
    if (followupIndex < pendingFollowups.length) {
      final next = pendingFollowups[followupIndex].replaceFirst(RegExp(r'^-\s*'), '');
      setState(() {
        messages.add(ChatMessage(text: next, isUser: false, isFollowUp: true));
      });
      chatContext.add({'role': 'assistant', 'content': next});
      followupIndex++;
    } else {
      isInFollowupFlow = false;
      pendingFollowups.clear();
      followupIndex = 0;
    }
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