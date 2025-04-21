import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/viewmodels/search_viewmodel.dart';

/// 상황별 필터링 함수
List<Lawyer> filterLawyersBySpecialty(String specialty, List<Lawyer> allLawyers) {
  final normalized = normalizeCategory(specialty);
  final keywords = categoryKeywordMap[normalized] ?? [normalized];

  return allLawyers.where((lawyer) {
    return lawyer.specialties.any((tag) =>
        keywords.any((keyword) =>
        tag.contains(keyword) || keyword.contains(tag)
        ));
  }).toList();
}

/// 지역별 필터링 함수
List<Lawyer> filterLawyersByRegion(String region, Map<String, List<Lawyer>> allLawyersByRegion) {
  return allLawyersByRegion[region] ?? [];
}