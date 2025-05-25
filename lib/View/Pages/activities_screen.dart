import 'package:flutter/material.dart';
import 'package:lingoverse_frontend/View/Pages/challenges_screen.dart';
import 'package:lingoverse_frontend/View/Pages/fluency_screen.dart';
import 'package:lingoverse_frontend/View/Pages/listen_screen.dart';
import 'package:lingoverse_frontend/View/Pages/speak_screen.dart';
import 'package:lingoverse_frontend/View/Widgets/activity_card.dart';
import 'package:lingoverse_frontend/View/Widgets/buttom_navbar.dart';
import 'package:lingoverse_frontend/View/Widgets/customed_text.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
  bottomNavigationBar: const BottomNavbar(forcedIndex: 1),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: CustomedText(
                  text: 'Activities and Games',
                  size: 24,
                  weight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              CustomedText(text: 'Games', size: 16, weight: FontWeight.bold),
              const SizedBox(height: 20),
              _navigateCard('Daily Challenges', Icons.calendar_month, const ChallengesPage()),

              const SizedBox(height: 30),
              CustomedText(text: 'Conversation', size: 16, weight: FontWeight.bold),
              const SizedBox(height: 20),
              _navigateCard('Voice Chatbot', Icons.voice_chat, const SpeakScreen()),
              const SizedBox(height: 10),
              _navigateCard('Listen', Icons.headphones, const ListenScreen()),

              const SizedBox(height: 30),
              CustomedText(text: 'Speech Recognition', size: 16, weight: FontWeight.bold),
              const SizedBox(height: 20),
              _navigateCard('Analyze your fluency', Icons.search_rounded, const FluencyScreen()),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navigateCard(String text, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => screen,
            settings: const RouteSettings(name: '/activities'), 
          ),
        );
      },
      child: ActivityCard(text: text, icon: icon, screen: screen),
    );
  }
}
