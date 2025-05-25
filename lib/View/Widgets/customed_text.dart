import 'package:flutter/material.dart';

class CustomedText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;

  const CustomedText({super.key, required this.text, required this.size, required this.weight});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:TextStyle(
        color: Colors.white,
        fontSize: size,
        fontWeight: weight,
      )
    );
  }
}