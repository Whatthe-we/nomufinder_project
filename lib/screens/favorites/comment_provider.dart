import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/comment.dart';

final commentListProvider = StateNotifierProvider.family<CommentListNotifier, List<Comment>, String>((ref, postId) {
  return CommentListNotifier(postId);
});

class CommentListNotifier extends StateNotifier<List<Comment>> {
  final String postId;

  CommentListNotifier(this.postId) : super([]);

  // 댓글 추가
  void addComment(String content, String author) {
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 임시 ID (실제 앱에서는 데이터베이스 ID 사용)
      postId: postId,
      author: author,
      content: content,
      createdAt: DateTime.now(),
    );
    state = [...state, newComment];
    // TODO: 실제 앱에서는 데이터베이스에 댓글 저장 로직을 추가해야 합니다.
  }

// (선택 사항) 댓글 목록 불러오기 - 실제 앱에서는 데이터베이스에서 불러와야 합니다.
// Future<void> loadComments() async {
//   // 데이터베이스에서 postId에 해당하는 댓글 목록을 불러와 state에 할당
//   // 예: state = await _commentService.getCommentsByPostId(postId);
// }
}