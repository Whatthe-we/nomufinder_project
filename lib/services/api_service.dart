import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // 환경 변수 또는 기본값 사용
  static final String baseUrl = dotenv.env['FASTAPI_BASE_URL'] ?? 'http://127.0.0.1:8000';

  // 자동완성 추천 API
  static Future<List<String>> getSuggestions(String query) async {
    try {
      // http.get으로 API 요청을 보냄
      final response = await http.get(Uri.parse('$baseUrl/suggest?query=$query'));

      // 응답 상태 코드가 200일 경우
      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes)); // 응답 본문을 디코딩
        return List<String>.from(json['suggestions']); // 'suggestions' 필드를 List<String>으로 변환하여 반환
      } else {
        throw Exception('추천 문장 불러오기 실패');
      }
    } catch (e) {
      print("자동완성 요청 실패: $e");
      return [];
    }
  }

  // 카테고리별 노무사 목록 API
  static Future<List<Map<String, dynamic>>> getLaborAttorneysByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/labor-attorneys?category=$category'));
    if (response.statusCode == 200) {
      // 응답 본문을 디코딩하여 한글 깨짐 방지
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(json['attorneys']); // 'attorneys' 필드를 List<Map<String, dynamic>>으로 변환하여 반환
    } else {
      throw Exception('노무사 목록 불러오기 실패');
    }
  }

  // 카테고리 분류 API
  static Future<String> classifyText(String input) async {
    final response = await http.post(
      Uri.parse('$baseUrl/classify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': input}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return json['category'] ?? '카테고리를 찾을 수 없습니다';
    } else {
      throw Exception('분류 실패: ${response.statusCode}');
    }
  }
}
