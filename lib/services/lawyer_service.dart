import 'package:project_nomufinder/models/lawyer.dart';

/// 상황별 필터링 함수
List<Lawyer> filterLawyersBySpecialty(String specialty, List<Lawyer> allLawyers) {
  return allLawyers.where((lawyer) => lawyer.specialties.contains(specialty)).toList();
}

/// 지역별 필터링 함수
List<Lawyer> filterLawyersByRegion(String region, Map<String, List<Lawyer>> allLawyersByRegion) {
  return allLawyersByRegion[region] ?? [];
}
