import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/post.dart';

final postListProvider = StateNotifierProvider<PostListNotifier, List<Post>>((ref) {
  return PostListNotifier();
});

class PostListNotifier extends StateNotifier<List<Post>> {
  PostListNotifier() : super([
    Post(id: '1', title: '퇴직금 문의', content: '퇴직금 제대로 받는 방법 알려주세요.', author: '사용자A'),
    Post(id: '2', title: '부당해고 상담', content: '해고 통보 받았습니다.', author: '사용자B'),
  ]);

  void addPost(Post post) {
    state = [post, ...state];
  }
}
