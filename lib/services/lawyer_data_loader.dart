import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:project_nomufinder/models/lawyer.dart';

Map<String, List<Lawyer>> lawyersByRegion = {};

final Map<String, List<String>> regionKeywords = {
  '서울': ['서울', '서울특별시'],
  '경기': ['경기', '경기도'],
  '춘천/강원': ['강원', '춘천'],
  '제주': ['제주', '제주특별자치도'],
  '인천/부천': ['인천', '부천', '인천광역시'],
  '대구/경북': ['대구', '경북', '대구광역시', '경상북도'],
  '청주/충북': ['청주', '충북', '충청북도'],
  '대전/충남/세종': ['대전', '충남', '세종', '대전광역시', '충청남도', '세종특별자치시'],
  '전주/전북': ['전주', '전북', '전라북도'],
  '부산/울산/경남': ['부산', '울산', '경남', '부산광역시', '울산광역시', '경상남도'],
  '광주/전남': ['광주', '전남', '광주광역시', '전라남도'],
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

    // specialty 보강
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