import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:project_nomufinder/models/lawyer.dart';

Map<String, List<Lawyer>> lawyersByRegion = {};

final Map<String, List<String>> regionKeywords = {
  '서울': ['서울'],
  '경기': ['경기'],
  '춘천/강원': ['강원', '춘천'],
  '제주': ['제주'],
  '인천/부천': ['인천', '부천'],
  '대구/경북': ['대구', '경북'],
  '청주/충북': ['청주', '충북'],
  '대전/충남/세종': ['대전', '충남', '세종'],
  '전주/전북': ['전주', '전북'],
  '부산/울산/경남': ['부산', '울산', '경남'],
  '광주/전남': ['광주', '전남'],
};

Future<void> loadLawyerData() async {
  final String jsonString =
  await rootBundle.loadString(
      'assets/lawyers_by_region_ver2.json'); // json 파일 업데이트
  final List<dynamic> jsonList = json.decode(jsonString);

  lawyersByRegion = {};

  for (var json in jsonList) {
    final lawyer = Lawyer.fromJson(json);
    final address = json['address'] ?? '';

    // ✅ specialty 강제 보강 처리
    if (lawyer.specialties.contains('괴롭힘·성희롱')) {
      if (!lawyer.specialties.contains('직장 내 괴롭힘')) {
        lawyer.specialties.add('직장 내 괴롭힘');
      }
      if (!lawyer.specialties.contains('직장 내 성희롱')) {
        lawyer.specialties.add('직장 내 성희롱');
      }
    }

    // address 기반으로 region 자동 매핑
    String matchedRegion = '기타';
    regionKeywords.forEach((region, keywords) {
      if (keywords.any((keyword) => address.contains(keyword))) {
        matchedRegion = region;
      }
    });

    // 해당 region에 노무사 추가
    if (!lawyersByRegion.containsKey(matchedRegion)) {
      lawyersByRegion[matchedRegion] = [];
    }
    lawyersByRegion[matchedRegion]!.add(lawyer);
  }
}