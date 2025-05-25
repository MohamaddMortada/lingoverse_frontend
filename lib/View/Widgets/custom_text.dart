import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
 final String text;
  CustomText({super.key, required this.text});

  @override
  
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return 
    Container(
      padding: EdgeInsets.all(10),
      width: width * 0.8,
      decoration: BoxDecoration(
        color:Colors.white,
        borderRadius: BorderRadius.circular(15),
        ),
      child: Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500
      ),
    ));
  }
}