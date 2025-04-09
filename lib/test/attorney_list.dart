import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'attorney_detail.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '노무사 매칭 앱',
      home: AttorneyListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AttorneyListPage extends StatefulWidget {
  @override
  _AttorneyListPageState createState() => _AttorneyListPageState();
}

class _AttorneyListPageState extends State<AttorneyListPage> {
  List<dynamic> _attorneys = [];

  // ✅ 스크롤 컨트롤러 추가
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchAttorneys();
  }

  Future<void> fetchAttorneys() async {
    final url = Uri.parse('http://10.0.2.2:8000/attorneys'); // 에뮬레이터에서는 10.0.2.2 사용
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes); // 한글 깨짐 방지
      setState(() {
        _attorneys = json.decode(decoded);
      });
    } else {
      print("API 호출 실패: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("노무사 리스트")),

      // ✅ Scrollbar + controller 적용
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _attorneys.length,
          itemBuilder: (context, index) {
            final a = _attorneys[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(a['이름'] ?? '이름 없음'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['지역/주소'] ?? '주소 없음'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (a['전문_분야'] ?? '')
                          .toString()
                          .split(',')
                          .map((field) => Chip(
                        label: Text(field.trim()),
                        backgroundColor: Colors.grey.shade200,
                      ))
                          .toList(),
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  final id = a['자격증번호'];
                  if (id != null && id is String) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttorneyDetailPage(id: id),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('선택한 노무사의 ID가 없습니다')),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}