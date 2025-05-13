import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'post_favorites_provider.dart';
import 'post_create_screen.dart';
import 'post_list_provider.dart';
import '../../models/post.dart';
import 'post_detail_screen.dart'; // PostDetailScreen import 확인!

class PostListScreen extends ConsumerWidget {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postListProvider);
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
                  builder: (_) => PostCreateScreen(onPostCreated: (post) {
                    ref.read(postListProvider.notifier).addPost(post);
                    Navigator.pop(context);
                  }),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: posts.length,
        separatorBuilder: (context, index) => const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ),
        itemBuilder: (context, index) {
          final post = posts[index];
          final isFav = favorites.contains(post);

          return InkWell( // InkWell로 감싸고 onTap 추가!
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(post: post), // PostDetailScreen으로 이동
                ),
              );
            },
            child: Padding( // 각 아이템에 Padding 추가
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 18, // 제목 크기 키우기
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    maxLines: 2, // 내용이 길면 잘라서 표시
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '작성자: ${post.author}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          ref.read(postFavoritesProvider.notifier).toggleFavorite(post);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}