import 'package:flutter/material.dart';
import 'package:lingoverse_frontend/View/Pages/login_screen.dart';
import 'package:lingoverse_frontend/View/Pages/splash_screen.dart';
import 'package:lingoverse_frontend/View/Widgets/button.dart';
import 'package:lingoverse_frontend/View/Widgets/customed_textbutton.dart';
import 'package:lingoverse_frontend/View/Widgets/customed_textfield.dart';
import 'package:lingoverse_frontend/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final AuthService authService = AuthService();

  void register() async {
  if (passwordController.text != confirmController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  bool success = await authService.register(
    nameController.text,
    emailController.text,
    passwordController.text,
  );

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Registration Successful!")),
    );
Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
    );  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Registration Failed")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      SingleChildScrollView(child:
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(alignment: Alignment.center,
            child:
            Image.asset('assets/parrot_logo_transparent-removebg-preview 2.png')),
            Text('Register', 
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontFamily: 'Inria Serif',
              fontWeight: FontWeight.w500
              ),
            ),
            SizedBox(height: 10,),
            CustomedTextfield(label: 'Name', controller: nameController), SizedBox(height: 10),
            CustomedTextfield(label: 'Email', controller: emailController), SizedBox(height: 10),
            CustomedTextfield(label: 'Phone Number', controller: phoneController), SizedBox(height: 10),
            CustomedTextfield(label: 'Password', controller: passwordController), SizedBox(height: 10),
            CustomedTextfield(label: 'Confirm Password', controller: confirmController), SizedBox(height: 10),
            SizedBox(height: 10),
CustomedButton(text: 'Register', ontap: register),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: TextStyle(color: Colors.white),
                ),
                CustomedTextbutton(
                  text: "Login",
                  ontap: () {
                       Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ],
            ),
            
          ],
        ),
      ),
    ));
  }
}
