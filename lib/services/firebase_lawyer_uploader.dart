import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseLawyerUploader {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> uploadLawyersFromJson() async {
    final jsonString = await rootBundle.loadString('assets/lawyers_by_region_ver2.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    for (final item in jsonData) {
      final data = {
        "name": item['name'] ?? '',
        "photo": _getRandomPhotoUrl(), // ✅ 무조건 랜덤 사진
        "desc": item['desc'] ?? '',
        "address": item['address'] ?? '',
        "comment": item['comment'] ?? '',
        "badges": item['badges'] ?? [],
        "price": item['price'] ?? [],
        "region": _extractRegion(item['address']), // ✅ 자동 지역 추출
        "reviews": item['reviews'] ?? 0,
        "gender": item['gender'] ?? '',
        "email": item['email'] ?? '',
        "phone": item['phone'] ?? '',
        "license_number": item['license_number'] ?? 0,
        "specialties": item['specialties'] ?? item['specialty'] ?? [],
        "consult": item['consult'] ?? ['전화상담', '영상상담', '방문상담'],
      };

      await _firestore.collection('lawyers').add(data);
      print("✅ 업로드 완료: ${data['name']}");
    }

    print("🎉 모든 노무사 업로드 완료!");
  }

  // ✅ 주소 기반 시/도 추출
  static String _extractRegion(String? address) {
    if (address == null) return '';

    final regionMap = {
      '서울특별시': '서울',
      '부산광역시': '부산',
      '대구광역시': '대구',
      '인천광역시': '인천',
      '광주광역시': '광주',
      '대전광역시': '대전',
      '울산광역시': '울산',
      '세종특별자치시': '세종',
      '세종': '세종',
      '경기도': '경기',
      '강원도': '강원',
      '충청북도': '충북',
      '충청남도': '충남',
      '전라북도': '전북',
      '전라남도': '전남',
      '경상북도': '경북',
      '경상남도': '경남',
      '제주': '제주',
    };

    for (final fullName in regionMap.keys) {
      if (address.contains(fullName)) {
        return regionMap[fullName]!;
      }
    }

    return '';
  }

  // ✅ 랜덤 프로필 이미지 URL 생성
  static String _getRandomPhotoUrl() {
    final gender = (DateTime.now().microsecond % 2 == 0) ? 'men' : 'women';
    final index = DateTime.now().millisecond % 100;
    return 'https://randomuser.me/api/portraits/$gender/$index.jpg';
  }
}
