import 'package:flutter/material.dart';

class CustomedButton extends StatelessWidget {
  final String text;
  final VoidCallback ontap;

  const CustomedButton({super.key, required this.text, required this.ontap});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(0),
      child: GestureDetector(
        onTap: ontap,
        child: Container(
          width: width,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).primaryColor,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
