import 'package:flutter/material.dart';
import 'package:lingoverse_frontend/View/Widgets/button.dart';
import 'package:lingoverse_frontend/View/Widgets/custom_text.dart';
import 'package:lingoverse_frontend/View/Widgets/customed_textbutton.dart';
import 'package:lingoverse_frontend/View/Widgets/customed_textfield.dart';

class ForgetCodeScreen extends StatelessWidget {
  final TextEditingController controller;
  const ForgetCodeScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Padding(padding: EdgeInsets.all(20),
    child: Column(children: [
      Image.asset('assets/parrot_logo_transparent-removebg-preview 2.png'),
      Align(alignment: Alignment.topLeft,child:
      Text('Input Your Code', style: TextStyle(color: Colors.white, fontSize: 24),)),SizedBox(height: 10,),
      CustomedTextfield(label: 'Input code', controller: controller),SizedBox(height: 10,),
      CustomedButton(text: 'Confirm', ontap: ()=>{}),
      Row(children: [
        CustomedTextbutton(text: 'Resend Code', ontap: ()=>{}),
        Text('in 59sec', style: TextStyle(color: Colors.white),),
      ],)
    ],),));
  }
}