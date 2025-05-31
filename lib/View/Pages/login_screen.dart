import 'package:flutter/material.dart';
import 'package:lingoverse_frontend/View/Pages/forget_password_screen.dart';
import 'package:lingoverse_frontend/View/Pages/main_screen.dart';
import 'package:lingoverse_frontend/View/Pages/register_screen.dart';
import 'package:lingoverse_frontend/View/Pages/splash_screen.dart';
import 'package:lingoverse_frontend/View/Widgets/button.dart';
import 'package:lingoverse_frontend/View/Widgets/customed_textbutton.dart';
import 'package:lingoverse_frontend/View/Widgets/customed_textfield.dart';
import 'package:lingoverse_frontend/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;


  void login() async {
    setState(() => isLoading = true);
    bool success = await authService.login(
      emailController.text.trim(),
passwordController.text.trim(),

    );
    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid Credentials")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(alignment: Alignment.center,
            child:
            Image.asset('assets/parrot_logo_transparent-removebg-preview 2.png')),
            Text('Login', 
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontFamily: 'Inria Serif',
              fontWeight: FontWeight.w500
              ),
            ),
            SizedBox(height: 10,),
            CustomedTextfield(label: 'Email', controller: emailController),
            SizedBox(height: 10),
            Container(
  padding: const EdgeInsets.symmetric(horizontal: 10),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Theme.of(context).primaryColor),
  ),
  child: TextField(
    controller: passwordController,
    obscureText: _obscurePassword,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: 'Password',
      labelStyle: const TextStyle(color: Color.fromARGB(255, 188, 188, 188)),
      border: InputBorder.none,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
    ),
  ),
),
CustomedTextbutton(text: 'Forgot your password', ontap: (){
  Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
}),            
            SizedBox(height: 10),
CustomedButton(text: 'Login', ontap: login),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(color: Colors.white),
                ),
                CustomedTextbutton(
                  text: "Register",
                  ontap: () {
                       Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}
