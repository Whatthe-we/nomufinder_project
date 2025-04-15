// lib/services/lawyer_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/lawyer.dart';

class LawyerService {
  static Future<Map<String, List<Lawyer>>> loadLawyersByRegion() async {
    final String jsonString = await rootBundle.loadString('assets/lawyers_by_region.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    return jsonData.map((region, lawyersJson) {
      final lawyers = (lawyersJson as List)
          .map((e) => Lawyer.fromJson(e))
          .toList();
      return MapEntry(region, lawyers);
    });
  }
}
