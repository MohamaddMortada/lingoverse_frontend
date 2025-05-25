import 'package:flutter/material.dart';

class CustomedTextbutton extends StatelessWidget {
  final String text;
  final VoidCallback ontap;

  const CustomedTextbutton({super.key, required this.text, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
              onPressed: ontap,
              child: Text(
                text,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
                )
            );
  }
}