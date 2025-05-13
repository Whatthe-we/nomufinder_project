class Comment {
  final String id;
  final String postId; // 해당 댓글이 속한 게시글 ID
  final String author; // 댓글 작성자
  final String content; // 댓글 내용
  final DateTime createdAt; // 댓글 작성 시간

  Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.createdAt,
  });
}