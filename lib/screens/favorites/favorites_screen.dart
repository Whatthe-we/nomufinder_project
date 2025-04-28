import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'post_favorites_provider.dart';
import '../../models/post.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(postFavoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('찜한 글'),
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('찜한 글이 없습니다.'))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final post = favorites[index];
          return ListTile(
            title: Text(post.title),
            subtitle: Text(post.content),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
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
