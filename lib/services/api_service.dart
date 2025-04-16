import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio();
  static String get baseUrl {
    if (kIsWeb) {
      return dotenv.env['FASTAPI_BASE_URL_WEB'] ?? 'http://localhost:8000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return dotenv.env['FASTAPI_BASE_URL_ANDROID'] ?? 'http://10.0.2.2:8000';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return dotenv.env['FASTAPI_BASE_URL_IOS'] ?? 'http://localhost:8000';
    } else {
      return dotenv.env['FASTAPI_BASE_URL'] ?? 'http://localhost:8000';
    }
  }

  // 자동완성 불러오기
  static Future<List<String>> getSuggestions(String query) async {
    try {
      final response = await _dio.get('$baseUrl/suggest?query=$query');
      if (response.statusCode == 200) {
        return (response.data['suggestions'] as List).cast<String>();
      } else {
        throw Exception('자동완성 불러오기 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('자동완성 불러오기 실패: ${e.message}');
    } catch (e) {
      throw Exception('자동완성 불러오기 실패: $e');
    }
  }

  // 카테고리 분류 API
  static Future<String> classifyText(String text) async {
    try {
      final response = await _dio.post('$baseUrl/classify', data: {'text': text});
      if (response.statusCode == 200) {
        return response.data['category'];
      } else {
        throw Exception('카테고리 분류 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('카테고리 분류 실패: ${e.message}');
    } catch (e) {
      throw Exception('카테고리 분류 실패: $e');
    }
  }

  // 카테고리별 노무사 목록 API
  static Future<List<Map<String, dynamic>>> getLaborAttorneysByCategory(String category) async {
    try {
      final response = await _dio.get('$baseUrl/lawyers/labor?region=$category');
      if (response.statusCode == 200) {
        return (response.data as List).cast<Map<String, dynamic>>();
      } else {
        throw Exception('노무사 목록 불러오기 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('노무사 목록 불러오기 실패: ${e.message}');
    } catch (e) {
      throw Exception('노무사 목록 불러오기 실패: $e');
    }
  }
}