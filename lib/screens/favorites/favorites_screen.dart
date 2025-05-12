import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'post_favorites_provider.dart';
import '../../models/post.dart';
import '../../widgets/common_header.dart'; // ✅ 공통 헤더 import

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(postFavoritesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const CommonHeader(), // ✅ 공통 헤더 적용
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              '찜한 글',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Open Sans',
                color: Color(0xFF0010BA),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: favorites.isEmpty
                  ? const Center(child: Text('찜한 글이 없습니다.'))
                  : ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final post = favorites[index];
                  return ListTile(
                    title: Text(post.title),
                    subtitle: Text(
                      post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        ref.read(postFavoritesProvider.notifier).toggleFavorite(post);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}