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
          '&q=직장 뉴스' // ✅ 복수 키워드 검색
          '&type=video'
          '&order=$order' // ✅ 매개변수로 받는 order 사용
          '&maxResults=10'
          '&key=$_apiKey'),
    );

    print('✅ YouTube API 응답 상태 코드: ${response.statusCode}');
    print('✅ YouTube API 응답 바디: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['items'] as List)
          .map((item) => YoutubeVideo.fromJson(item))
          .toList();
    } else {
      throw Exception('유튜브 뉴스 로딩 실패');
    }
  }
}