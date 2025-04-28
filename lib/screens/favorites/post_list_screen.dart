import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'post_favorites_provider.dart';
import 'post_create_screen.dart';
import 'post_list_provider.dart'; // 새로 만든 provider import!
import '../../models/post.dart';

class PostListScreen extends ConsumerWidget {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postListProvider); // posts 상태 가져오기
    final favorites = ref.watch(postFavoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('상담글 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PostCreateScreen(onPostCreated: (post) {
                        ref.read(postListProvider.notifier).addPost(
                            post); // 글 추가!
                        Navigator.pop(context);
                      }),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final isFav = favorites.contains(post);

          return ListTile(
            title: Text(post.title),
            subtitle: Text(post.content),
            trailing: IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: () {
                ref.read(postFavoritesProvider.notifier).toggleFavorite(post);
              },
            ),
          );
        },
      ),
    );
  }
}