import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/post.dart'; // 모델 위치 맞춰줘

/// 찜한 글 목록 관리하는 Provider
final postFavoritesProvider = StateNotifierProvider<PostFavoritesNotifier, List<Post>>((ref) {
  return PostFavoritesNotifier();
});

/// 찜한 글들을 저장하는 StateNotifier
class PostFavoritesNotifier extends StateNotifier<List<Post>> {
  PostFavoritesNotifier() : super([]);

  void toggleFavorite(Post post) {
    if (state.contains(post)) {
      state = state.where((item) => item.id != post.id).toList();
    } else {
      state = [...state, post];
    }
  }

  bool isFavorite(Post post) {
    return state.any((item) => item.id == post.id);
  }
}
