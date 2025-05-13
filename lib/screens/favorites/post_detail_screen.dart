import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/post.dart';
import '../favorites/comment_provider.dart';

class PostDetailScreen extends ConsumerWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentList = ref.watch(commentListProvider(post.id));
    final commentNotifier = ref.read(commentListProvider(post.id).notifier);
    final TextEditingController _commentController = TextEditingController();
    final String currentUser = '익명 사용자'; // TODO: 실제 앱에서는 인증된 사용자 정보 사용

    return Scaffold(
      appBar: AppBar(
        leading: IconButton( // 뒤로 가기 버튼 추가
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // title: Text(post.title), // 기존 제목 제거
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 게시글 상세 내용
            Text(
              post.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87), // 제목 스타일 변경
            ),
            const SizedBox(height: 8),
            Text('작성자: ${post.author}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Text(post.content, style: const TextStyle(fontSize: 16, color: Colors.black87)), // 본문 스타일 변경
            const SizedBox(height: 24), // 간격 증가
            const Divider(thickness: 1), // 구분선 추가
            const SizedBox(height: 16),

            // 댓글 목록
            const Text('댓글', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: commentList.length,
                itemBuilder: (context, index) {
                  final comment = commentList.reversed.toList()[index]; // 최신 댓글이 먼저 보이도록 순서 변경
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(comment.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text(
                              '${comment.createdAt.year}-${comment.createdAt.month}-${comment.createdAt.day} ${comment.createdAt.hour}:${comment.createdAt.minute}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(comment.content),
                        if (index < commentList.length - 1) // 마지막 댓글 아래에는 구분선 생략
                          const Divider(thickness: 0.5, color: Colors.grey),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // 댓글 입력 폼
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    final commentText = _commentController.text.trim();
                    if (commentText.isNotEmpty) {
                      commentNotifier.addComment(commentText, currentUser);
                      _commentController.clear();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}