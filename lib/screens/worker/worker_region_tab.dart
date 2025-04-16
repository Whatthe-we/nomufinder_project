import 'package:flutter/material.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/screens/lawyer_search/lawyer_list_screen.dart';
import 'package:project_nomufinder/services/lawyer_data_loader.dart';
import 'package:project_nomufinder/screens/worker/region_map_screen.dart';

class WorkerRegionScreen extends StatelessWidget {
  const WorkerRegionScreen({super.key});

  final List<String> regions = const [
    '서울', '경기',
    '춘천/강원', '제주',
    '인천/부천', '대구/경북',
    '청주/충북', '대전/충남/세종',
    '전주/전북', '부산/울산/경남',
    '광주/전남', '+ 전체보기',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          itemCount: regions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final region = regions[index];
            final isLast = region == '+ 전체보기';

            return GestureDetector(
              onTap: () {
                if (isLast) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegionMapScreen(),
                    ),
                  );
                  return;
                }

                final lawyers = lawyersByRegion[region] ?? [];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LawyerListScreen(
                      title: region,
                      region: region, // region 값을 추가하여 전달
                      lawyers: lawyers,
                    ),
                  ),
                );
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isLast ? Colors.white : const Color(0xFFF2F1FA),
                  borderRadius: BorderRadius.circular(12),
                  border: isLast ? Border.all(color: Colors.grey.shade300) : null,
                ),
                child: Center(
                  child: Text(
                    region,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}