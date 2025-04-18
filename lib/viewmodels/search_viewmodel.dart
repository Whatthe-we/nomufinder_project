import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// 카테고리 상태 관리
final categoryProvider = StateProvider<String?>((ref) => null);

// 분류된 카테고리
final classifyTextProvider = StateProvider<String>((ref) => '');

final userTypeProvider = StateProvider<String>((ref) => 'worker');

// 분류 요청을 처리하는 프로바이더
final classifyTextAsyncProvider = FutureProvider.autoDispose.family<String, String>((ref, input) async {
  final category = await ApiService.classifyText(input);
  return category;
});