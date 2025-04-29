import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/youtube_video.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class YoutubeService {
  static final _apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
  static const _baseUrl = 'https://www.googleapis.com/youtube/v3/search';

  /// 노동 관련 유튜브 뉴스 가져오기
  static Future<List<YoutubeVideo>> fetchLaborNewsVideos({String order = 'date'}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?part=snippet'
          '&q=직장 뉴스'
          '&type=video'
          '&order=$order'
          '&maxResults=10'
          '&key=$_apiKey'),
    );

    print('✅ 뉴스 응답 상태 코드: ${response.statusCode}');
    print('✅ 뉴스 응답 바디: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['items'] as List)
          .map((item) => YoutubeVideo.fromJson(item))
          .toList();
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
