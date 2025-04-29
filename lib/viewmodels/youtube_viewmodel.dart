import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/youtube_service.dart';
import '../models/youtube_video.dart';

final youtubeNewsProvider = FutureProvider<List<YoutubeVideo>>((ref) async {
  return await YoutubeService.fetchLaborNewsVideos();
});

final youtubePlaylistProvider = FutureProvider.family<List<YoutubeVideo>, String>((ref, playlistId) async {
  return await YoutubeService.fetchPlaylistVideos(playlistId);
});