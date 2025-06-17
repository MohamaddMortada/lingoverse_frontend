import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lingoverse_frontend/View/Widgets/customed_text.dart';

class ActivityCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Widget screen;

  const ActivityCard({
    super.key,
    required this.text,
    required this.icon,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF003247),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomedText(text: text, size: 14, weight: FontWeight.w400),
          Icon(icon, color: Colors.white),
        ],
      ),
    );
  }
}
