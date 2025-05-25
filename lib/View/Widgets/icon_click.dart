import 'package:flutter/material.dart';

class IconClick extends StatelessWidget {
  final String url;
  const IconClick({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Image.asset(url,width: width*0.05,height: width*0.05,);
  }
}