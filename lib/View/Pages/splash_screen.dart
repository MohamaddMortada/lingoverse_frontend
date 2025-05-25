import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lingoverse_frontend/View/Pages/main_screen.dart';
import 'package:lingoverse_frontend/View/Pages/profile_screen.dart';
import 'package:lingoverse_frontend/View/Pages/stage_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/parrot_logo_transparent-removebg-preview 2.png',
              ),
              const SizedBox(height: 50),
              const Text(
                'Lingoverse',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                ),
              ),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}
