import 'package:flutter/material.dart';
import 'package:lingoverse_frontend/Services/api_client_service.dart';
import 'package:lingoverse_frontend/View/Widgets/customed_text.dart';
import 'package:lingoverse_frontend/View/Widgets/button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final ApiClientService _api = ApiClientService(baseUrl: 'http://127.0.0.1:8000/api');
  String _message = '';
  bool _isLoading = false;

  Future<void> _submitEmail() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final res = await _api.post('/forgot-password', {
      'email': _emailController.text.trim(),
    });

    setState(() {
      _isLoading = false;
      _message = res.success
          ? 'Reset link sent to your email.'
          : 'Failed to send reset link. Please check your email.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFF00131F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00111C),
        title: const Text('Forgot Password', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomedText(
              text: 'Enter your email to receive a password reset link',
              size: 16,
              weight: FontWeight.w400,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryColor),
              ),
              child: TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 188, 188, 188)),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator(color: Colors.white)
            else
              CustomedButton(text: 'Send Reset Link', ontap: _submitEmail),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)
              CustomedText(
                text: _message,
                size: 14,
                weight: FontWeight.w300,
              ),
          ],
        ),
      ),
    );
  }
}
