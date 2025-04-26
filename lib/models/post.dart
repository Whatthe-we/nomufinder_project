class Post {
  final String id;
  final String title;
  final String content;
  final String author;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Post && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
