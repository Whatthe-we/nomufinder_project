import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:project_nomufinder/models/lawyer.dart';

class ApiService {
  static final Dio _dio = Dio();

  // 환경에 따른 baseUrl 설정
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

  // 카테고리로 필터링된 노무사 목록 가져오기
  static Future<List<Lawyer>> getLaborAttorneysBySpecialty(String specialty) async {
    try {
      // specialty를 사용하여 API 호출
      final response = await _dio.get('$baseUrl/lawyers?specialty=$specialty');
      if (response.statusCode == 200) {
        // API 응답에서 노무사 목록을 Lawyer 객체로 변환
        List<Lawyer> lawyers = (response.data as List)
            .map((lawyerData) => Lawyer.fromJson(lawyerData))
            .toList();
        return lawyers;
      } else {
        throw Exception('카테고리별 노무사 목록 불러오기 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('카테고리별 노무사 목록 불러오기 실패: ${e.message}');
    } catch (e) {
      throw Exception('카테고리별 노무사 목록 불러오기 실패: $e');
    }
  }

  // 자동완성 불러오기
  static Future<List<String>> getSuggestions(String query) async {
    try {
      final response = await _dio.get('$baseUrl/suggest?query=$query');
      if (response.statusCode == 200) {
        // 카테고리와 함께 자동완성 키워드 반환
        final category = response.data['category'];
        final suggestions = (response.data['suggestions'] as List).cast<String>();
        return suggestions;
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
}