import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/youtube_video.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';

class YoutubeService {
  static final _apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
  static const _baseUrl = 'https://www.googleapis.com/youtube/v3/search';

  static final List<String> _keywords = ['직장 뉴스','취업 뉴스','기업 뉴스','근무 뉴스'];

  static Future<List<YoutubeVideo>> fetchLaborNewsVideos() async {
    final keyword = (_keywords..shuffle()).first;
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 30));
    final publishedAfter = oneWeekAgo.toUtc().toIso8601String();

    final response = await http.get(
      Uri.parse('$_baseUrl?part=snippet'
          '&q=$keyword'
          '&type=video'
          '&order=date'
          '&publishedAfter=$publishedAfter'
          '&videoDuration=medium'  // ✅ 쇼츠 제외
          '&maxResults=10'
          '&key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final videos = (data['items'] as List)
          .map((item) => YoutubeVideo.fromJson(item))
          .where((video) => [
        'KBS',
        'MBC',
        'SBS',
        'JTBC',
        'YTN',
        '연합뉴스',
        'MBN',
        'TVCHOSUN',
        '채널A',
        '한국경제TV',
      ].any((name) => video.channelTitle?.contains(name) ?? false))
          .toList();

      return videos;
    } else {
      throw Exception('유튜브 뉴스 로딩 실패');
    }
  }

  /// 플레이리스트 기반 영상 가져오기
  static Future<List<YoutubeVideo>> fetchPlaylistVideos(String playlistId) async {
    final response = await http.get(
      Uri.parse(
        'https://www.googleapis.com/youtube/v3/playlistItems'
            '?part=snippet'
            '&order=date'
            '&maxResults=10'
            '&playlistId=$playlistId'
            '&key=$_apiKey',
      ),
    );

    print('✅ 플레이리스트 응답 상태 코드: ${response.statusCode}');
    print('✅ 플레이리스트 응답 바디: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['items'] as List)
          .map((item) => YoutubeVideo(
        videoId: item['snippet']['resourceId']['videoId'],
        title: item['snippet']['title'],
        description: item['snippet']['description'],
        thumbnailUrl: item['snippet']['thumbnails']['medium']['url'],
        channelTitle: item['snippet']['channelTitle'], // ✅ 추가
      ))
          .toList();
    } else {
      throw Exception('플레이리스트 영상 로딩 실패');
    }
  }
}