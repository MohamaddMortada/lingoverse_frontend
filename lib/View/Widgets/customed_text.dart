import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
class CustomedText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;

  const CustomedText({
    super.key,
    required this.text,
    required this.size,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr(), // This ensures it updates when locale changes
      style: TextStyle(
        color: Colors.white,
        fontSize: size,
        fontWeight: weight,
      ),
    );
  }
}
