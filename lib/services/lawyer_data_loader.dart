import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:project_nomufinder/models/lawyer.dart';

Map<String, List<Lawyer>> lawyersByRegion = {};

Future<void> loadLawyerData() async {
  final String jsonString =
  await rootBundle.loadString('assets/lawyers_by_region.json');
  final Map<String, dynamic> jsonMap = json.decode(jsonString);

  lawyersByRegion = jsonMap.map((region, list) {
    final lawyerList = (list as List)
        .map((lawyerJson) => Lawyer.fromJson(lawyerJson))
        .toList();
    return MapEntry(region, lawyerList);
  });
}