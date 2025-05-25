import 'package:flutter/material.dart';

class CustomedTextfield extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const CustomedTextfield({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
      child: TextField(
        style: TextStyle(color: Colors.white),
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: const Color.fromARGB(255, 188, 188, 188))),
      ),
    );
  }
}
