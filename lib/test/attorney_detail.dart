import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' show utf8;

class AttorneyDetailPage extends StatefulWidget {
  final String id;

  AttorneyDetailPage({required this.id});

  @override
  _AttorneyDetailPageState createState() => _AttorneyDetailPageState();
}

class _AttorneyDetailPageState extends State<AttorneyDetailPage> {
  Map<String, dynamic>? attorney;

  @override
  void initState() {
    super.initState();
    fetchAttorneyDetail();
  }

  Future<void> fetchAttorneyDetail() async {
    final url = Uri.parse('http://10.0.2.2:8000/attorney/id/${widget.id}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes); // 한글 깨짐 방지
      setState(() {
        attorney = json.decode(decoded);
      });
    } else {
      print("상세 정보 가져오기 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (attorney == null) {
      return Scaffold(
        appBar: AppBar(title: Text("노무사 정보")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(attorney!['이름'] ?? '상세정보')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("이름: ${attorney!['이름'] ?? '없음'}"),
            Text("성별: ${attorney!['성별'] ?? '없음'}"),
            Text("소속: ${attorney!['소속_노무법인'] ?? '없음'}"),
            Text("주소: ${attorney!['지역/주소'] ?? '없음'}"),
            Text("연락처: ${attorney!['연락처'] ?? '없음'}"),
            Text("이메일: ${attorney!['이메일'] ?? '없음'}"),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: (attorney!['전문_분야'] ?? '')
                  .toString()
                  .split(',')
                  .map((f) => Chip(label: Text(f.trim())))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}