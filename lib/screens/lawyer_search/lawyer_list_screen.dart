import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/screens/lawyer_search/lawyer_detail_screen.dart';
import 'package:project_nomufinder/screens/reservation/reservation_screen.dart';
import 'package:project_nomufinder/widgets/filter_bottom_sheet.dart';
import 'package:project_nomufinder/viewmodels/search_viewmodel.dart';

class LawyerListScreen extends ConsumerStatefulWidget {
  final String title;
  final List<Lawyer> lawyers;
  final String? category; // nullable로 변경해도 안전하게 처리

  const LawyerListScreen({
    super.key,
    required this.title,
    required this.lawyers,
    this.category,
  });

  @override
  ConsumerState<LawyerListScreen> createState() => _LawyerListScreenState();
}

class _LawyerListScreenState extends ConsumerState<LawyerListScreen> {
  @override
  void initState() {
    super.initState();
    print('📦 전달된 노무사 수: ${widget.lawyers.length}');
    print('✅ 전달된 category: ${widget.category}');

    Future.microtask(() {
      ref.read(allLawyersProvider.notifier).state = widget.lawyers;

      // ✅ 전달된 lawyers 디버깅 출력
      for (var lawyer in widget.lawyers) {
        print('🧠 ${lawyer.name} / specialties: ${lawyer.specialties}');
      }

      // ✅ normalize 적용
      final normalizedCategory = normalizeCategory(widget.category ?? '');
      print('🧪 normalizedCategory: $normalizedCategory');

      // ✅ 지역명이 아닌 경우에만 카테고리 상태로 반영
      if (!regionKeywords.keys.contains(normalizedCategory)) {
        ref
            .read(categoryProvider.notifier)
            .state = normalizedCategory;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredLawyers = ref.watch(filteredLawyersProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontFamily: 'OpenSans')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: filteredLawyers.length,
            itemBuilder: (context, index) {
              final lawyer = filteredLawyers[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => LawyerDetailScreen(lawyer: lawyer)));
                },
                child: _buildLawyerCard(context, lawyer),
              );
            },
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.5 - 65,
            bottom: 20,
            child: SizedBox(
              width: 130,
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const FilterBottomSheet(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[600]!.withOpacity(0.7), // 80% 불투명
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  '필터 적용하기',
                  style: TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'OpenSans'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLawyerCard(BuildContext context, Lawyer lawyer) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(lawyer.profileImage),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lawyer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'OpenSans')),
                    const SizedBox(height: 4),
                    Text(lawyer.description, style: const TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'OpenSans')),
                    const SizedBox(height: 4),
                    Text(lawyer.comment, style: const TextStyle(fontSize: 13, fontFamily: 'OpenSans')),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: lawyer.badges.map((badge) => Chip(
                        label: Text(badge, style: const TextStyle(fontSize: 10, color: Colors.white)),
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.zero,
                      )).toList(),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: lawyer.specialties.map((tag) => TagChip(tag: tag)).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ReservationScreen(lawyer: lawyer)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0010BA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("예약하기", style: TextStyle(fontSize: 13, fontFamily: 'OpenSans')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFee('전화상담', lawyer.phoneFee),
              _buildFee('영상상담', lawyer.videoFee),
              _buildFee('방문상담', lawyer.visitFee),
              const Spacer(),
              Icon(Icons.star, color: Colors.orange, size: 14),
              Text('${lawyer.reviews} 후기', style: const TextStyle(fontSize: 12, fontFamily: 'OpenSans')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFee(String label, int fee) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'OpenSans')),
          Text('${_formatPrice(fee)}원', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'OpenSans')),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
    );
  }
}

class TagChip extends StatelessWidget {
  final String tag;
  const TagChip({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F1FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$tag',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
          fontFamily: 'OpenSans',
        ),
      ),
    );
  }
}