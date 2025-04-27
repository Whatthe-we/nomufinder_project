import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:project_nomufinder/models/lawyer.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
    ),
  );

  // ✅ 검색용 BaseUrl
  static String get searchBaseUrl {
    if (kIsWeb) {
      return dotenv.env['FASTAPI_SEARCH_BASE_URL_WEB'] ?? 'http://localhost:8001';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return dotenv.env['FASTAPI_SEARCH_BASE_URL_ANDROID'] ?? 'http://10.0.2.2:8001';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return dotenv.env['FASTAPI_SEARCH_BASE_URL_IOS'] ?? 'http://localhost:8001';
    } else {
      return dotenv.env['FASTAPI_SEARCH_BASE_URL'] ?? 'http://localhost:8001';
    }
  }

  // ✅ 챗봇용 BaseUrl
  static String get chatbotBaseUrl {
    if (kIsWeb) {
      return dotenv.env['FASTAPI_CHATBOT_BASE_URL_WEB'] ?? 'http://localhost:8000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return dotenv.env['FASTAPI_CHATBOT_BASE_URL_ANDROID'] ?? 'http://10.0.2.2:8000';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return dotenv.env['FASTAPI_CHATBOT_BASE_URL_IOS'] ?? 'http://localhost:8000';
    } else {
      return dotenv.env['FASTAPI_CHATBOT_BASE_URL'] ?? 'http://localhost:8000';
    }
  }

  // 카테고리 분류 함수
  static Future<String> classifyText(String text) async {
    final response = await _dio.post(
      '$searchBaseUrl/classify', // 🔥 여기
      data: {'text': text},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    if (response.statusCode == 200) {
      return response.data['category']; // 문자열 반환
    } else {
      throw Exception('분류 실패: ${response.statusCode}');
    }
  }

  // 자동완성 불러오기
  static Future<Map<String, dynamic>> getSuggestions(String query) async {
    try {
      final response = await _dio.get('$searchBaseUrl/suggest?query=$query'); // 🔥 여기
      if (response.statusCode == 200) {
        final category = response.data['category'];
        final suggestions = (response.data['suggestions'] as List).cast<String>();
        return {
          'category': category,
          'suggestions': suggestions,
        };
      } else {
        throw Exception('자동완성 불러오기 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('자동완성 불러오기 실패: ${e.message}');
    } catch (e) {
      throw Exception('자동완성 불러오기 실패: $e');
    }
  }
}