import 'package:flutter/material.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/screens/lawyer_search/lawyer_list_screen.dart';
import 'package:project_nomufinder/services/lawyer_data_loader.dart';

class RegionMapScreen extends StatelessWidget {
  const RegionMapScreen({super.key});

  void _onRegionSelected(BuildContext context, String region) {
    final lawyers = lawyersByRegion[region] ?? [];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LawyerListScreen(
          title: region,
          lawyers: lawyers,
          region: region, // region 값 전달
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("지역 선택")),
      body: InteractiveViewer(
        maxScale: 3.0,
        minScale: 0.5,
        boundaryMargin: const EdgeInsets.all(100),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/korea_map.png',
                fit: BoxFit.contain,
              ),
            ),

            // 📍 위치 조정 완료된 지역 버튼들
            Positioned(top: 145, left: 100, child: _regionButton(context, '서울')),
            Positioned(top: 175, left: 100, child: _regionButton(context, '경기')),
            Positioned(top: 155, left: 40, child: _regionButton(context, '인천/부천')),
            Positioned(top: 120, left: 260, child: _regionButton(context, '춘천/강원')),
            Positioned(top: 275, left: 65, child: _regionButton(context, '대전/충남/세종')),
            Positioned(top: 265, left: 175, child: _regionButton(context, '청주/충북')),
            Positioned(top: 375, left: 120, child: _regionButton(context, '전주/전북')),
            Positioned(top: 450, left: 100, child: _regionButton(context, '광주/전남')),
            Positioned(top: 425, left: 230, child: _regionButton(context, '부산/울산/경남')),
            Positioned(top: 320, left: 280, child: _regionButton(context, '대구/경북')),
            Positioned(bottom: 30, left: 50, child: _regionButton(context, '제주')),
          ],
        ),
      ),
    );
  }

  Widget _regionButton(BuildContext context, String region) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.3),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      onPressed: () => _onRegionSelected(context, region),
      child: Text(region, style: const TextStyle(fontSize: 11)),
    );
  }
}