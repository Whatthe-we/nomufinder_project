import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_nomufinder/models/lawyer.dart';
import 'package:project_nomufinder/screens/lawyer_search/lawyer_detail_screen.dart';
import 'package:project_nomufinder/screens/reservation/reservation_screen.dart';
import 'package:project_nomufinder/widgets/filter_bottom_sheet.dart';
import 'package:project_nomufinder/viewmodels/search_viewmodel.dart';
import 'package:project_nomufinder/services/firebase_lawyer_service.dart';

class LawyerListScreen extends ConsumerStatefulWidget {
  final String title;
  final String? category;

  const LawyerListScreen({
    super.key,
    required this.title,
    this.category,
  });

  @override
  ConsumerState<LawyerListScreen> createState() => _LawyerListScreenState();
}

class _LawyerListScreenState extends ConsumerState<LawyerListScreen> {
  late Future<List<Lawyer>> _lawyersFuture;

  @override
  void initState() {
    super.initState();

    _lawyersFuture = FirebaseLawyerService.fetchLawyers().then((lawyers) {
      ref.read(allLawyersProvider.notifier).state = lawyers;

      if (widget.category != null && widget.category!.isNotEmpty) {
        final normalizedCategory = normalizeCategory(widget.category!);
        if (!regionKeywords.keys.contains(normalizedCategory)) {
          ref.read(categoryProvider.notifier).state = normalizedCategory;
        }
      }


      return lawyers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredLawyers = ref.watch(filteredLawyersProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: _lawyersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: filteredLawyers.length,
                itemBuilder: (context, index) {
                  final lawyer = filteredLawyers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LawyerDetailScreen(lawyerId: lawyer.id), // ID만 넘기기
                        ),
                      );
                    },
                    child: _buildLawyerCard(context, lawyer),
                  );
                },
              );
            },
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.5 - 60,
            bottom: 20,
            child: SizedBox(
              width: 120,
              height: 40,
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
                  backgroundColor: Colors.blueGrey[600]!.withOpacity(0.7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.zero,
                ),
                child: const Text('필터 적용하기',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'OpenSans')),
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
              const SizedBox(width: 4),
              CircleAvatar(
                radius: 38, // 확대
                backgroundImage: NetworkImage(lawyer.profileImage),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lawyer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'OpenSans')),
                    const SizedBox(height: 4),
                    Text(lawyer.description, style: const TextStyle(fontSize: 13, color: Colors.grey, fontFamily: 'OpenSans')),
                    const SizedBox(height: 4),
                    Text(lawyer.comment, style: const TextStyle(fontSize: 13, fontFamily: 'OpenSans')),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: lawyer.badges.map((badge) => Chip(
                        label: Text(badge, style: const TextStyle(fontSize: 11, color: Colors.white)),
                        backgroundColor: const Color(0xFF0010BA),
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
                child: const Text("예약하기", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'OpenSans')),
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
              Text('${lawyer.reviews.length} 후기', style: const TextStyle(fontSize: 12, fontFamily: 'OpenSans')),
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
    return price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},');
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
      child: Text('#$tag', style: const TextStyle(fontSize: 12, color: Colors.black87, fontFamily: 'OpenSans')),
    );
  }
}
