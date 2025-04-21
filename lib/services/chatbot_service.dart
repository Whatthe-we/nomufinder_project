import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotService {
  static final String baseUrl = dotenv.env['FASTAPI_BASE_URL'] ?? 'http://127.0.0.1:8000';

  static Future<String> getRagResponse(String query) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rag'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'];
    } else {
      throw Exception('RAG 응답 실패: ${response.body}');
    }
  }
}