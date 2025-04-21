import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_nomufinder/config/providers.dart';
import 'package:project_nomufinder/viewmodels/search_viewmodel.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGender = ref.watch(selectedGenderProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);

    final genderOptions = ['전체', '남', '여'];
    final regionOptions = [
      "전국", "서울", "경기", "제주", "인천/부천", "춘천/강원",
      "대전/충남/세종", "청주/충북", "광주/전남", "전주/전북", "부산/울산/경남", "대구/경북"
    ];

    // ✅ 초기 상태와 비교해서 변경 여부 판단
    final bool isChanged = selectedGender != '전체' || selectedRegion != '전국';

    return Container(
      height: 600,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ 상단 - 타이틀 & 초기화 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("상세필터", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  // 초기화 실행
                  ref.read(selectedGenderProvider.notifier).state = '전체';
                  ref.read(selectedRegionProvider.notifier).state = '전국';
                },
                child: const Text("초기화", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ✅ 성별 선택
          const Text("성별", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: genderOptions.map((g) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(g),
                selected: selectedGender == g,
                onSelected: (_) => ref.read(selectedGenderProvider.notifier).state = g,
              ),
            )).toList(),
          ),

          const SizedBox(height: 24),

          // ✅ 지역 선택
          const Text("지역", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: regionOptions.map((r) => ChoiceChip(
              label: Text(r),
              selected: selectedRegion == r,
              onSelected: (_) => ref.read(selectedRegionProvider.notifier).state = r,
            )).toList(),
          ),

          const Spacer(),

          // ✅ 하단 버튼
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 닫기만 해도 상태는 반영됨
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isChanged ? const Color(0xFF0010BA) : Colors.grey,
              ),
              child: Text(
                isChanged ? "필터 적용하기" : "선택 없음",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}