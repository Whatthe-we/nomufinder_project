import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/lawyer.dart';

// 오타/공백 등 정규화(normalize)
String normalizeCategory(String input) {
  final cleaned = input.replaceAll(RegExp(r'\\s+'), ' ').trim();

  for (final key in categoryKeywordMap.keys) {
    final keyKeywords = categoryKeywordMap[key]!;
    if (keyKeywords.any((k) => k.contains(cleaned) || cleaned.contains(k))) {
      return key;
    }
  }

  // 기존 로직도 유지
  for (final key in categoryKeywordMap.keys) {
    final noSpaceKey = key.replaceAll(' ', '');
    final noSpaceInput = cleaned.replaceAll(' ', '');
    if (noSpaceKey == noSpaceInput) return key;
  }

  return cleaned;
}

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

// ✅ 필터 상태 추가
final selectedGenderProvider = StateProvider<String>((ref) => '전체');
final selectedRegionProvider = StateProvider<String>((ref) => '전국');

// ✅ 전체 노무사 리스트
final allLawyersProvider = StateProvider<List<Lawyer>>((ref) => []);

// ✅ 지역 키워드 매핑 - 여기에 추가!
final Map<String, List<String>> regionKeywords = {
  '전국': [],
  '서울': ['서울'],
  '경기': ['경기'],
  '청주/충북': ['충북', '청주'],
  '대전/충남/세종': ['대전', '충남', '세종'],
  '부산/울산/경남': ['부산', '울산', '경남'],
  '전주/전북': ['전주', '전북'],
  '광주/전남': ['광주', '전남'],
  '춘천/강원': ['춘천', '강원'],
  '제주': ['제주'],
  '인천/부천': ['인천', '부천'],
  '대구/경북': ['대구', '경북'],
};

final Map<String, List<String>> categoryKeywordMap = {
  '직장 내 괴롭힘': ['괴롭힘', '괴롭힘·성희롱', '직장내괴롭힘'],
  '직장 내 성희롱': ['성희롱', '괴롭힘·성희롱', '직장내성희롱'],
  '근무조건': ['근로계약', '근로계약/근무조건 상담'],
  '부당해고': ['부당해고'],
  '임금 체불': ['임금체불', '임금/퇴직금'],
  '산업재해': ['산재', '산업재해'],
  '직장 내 차별': ['차별'],
  // 필요한 매핑 계속 추가
};

// 필터 적용된 노무사 리스트
final filteredLawyersProvider = Provider<List<Lawyer>>((ref) {
  final gender = ref.watch(selectedGenderProvider);
  final region = ref.watch(selectedRegionProvider);
  final all = ref.watch(allLawyersProvider);
  final selectedCategory = ref.watch(categoryProvider); // ✅ 카테고리 추가

  final filtered = all.where((lawyer) {
    final genderMatch = (gender == '전체' || lawyer.gender == gender);
    final regionMatch = region == '전국' ||
        regionKeywords[region]?.any((keyword) =>
            lawyer.address.toLowerCase().contains(keyword.toLowerCase())
        ) == true;

    final categoryMatch = () {
      if (selectedCategory == null || selectedCategory == '전체') return true;

      // ✅ 지역명과 겹치는 카테고리는 무시
      if (regionKeywords.keys.contains(selectedCategory)) return true;

      final keywords = categoryKeywordMap[selectedCategory];
      if (keywords != null) {
        return lawyer.specialties.any((tag) =>
            keywords.any((keyword) =>
            tag.contains(keyword) || keyword.contains(tag)));
      }

      // 키워드 없을 경우에도 양방향 대응
      return lawyer.specialties.any((tag) =>
      tag.contains(selectedCategory) || selectedCategory.contains(tag));
    }();

    return genderMatch && regionMatch && categoryMatch;
  }).toList();

  print('[필터 디버깅] 성별: $gender / 지역: $region / 카테고리: $selectedCategory → 결과 ${filtered.length}명');
  return filtered;
});