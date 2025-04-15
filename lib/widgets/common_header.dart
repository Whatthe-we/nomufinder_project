// lib/widgets/common_header.dart
import 'package:flutter/material.dart';

class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'NOMU FINDER',
          style: TextStyle(
            color: Color(0xFF000FBA),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        const Spacer(),
        Icon(Icons.search, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '마이페이지',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
