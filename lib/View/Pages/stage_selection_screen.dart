import 'package:flutter/material.dart';
import 'package:lingoverse_frontend/View/Widgets/buttom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'league_screen.dart';

class StageSelectionScreen extends StatefulWidget {
  const StageSelectionScreen({super.key});

  @override
  State<StageSelectionScreen> createState() => _StageSelectionScreenState();
}

class _StageSelectionScreenState extends State<StageSelectionScreen> {
  int _unlockedStage = 1;

  final List<String> _stages = [
    'Beginner',
    'Basic',
    'Elementary',
    'Pre-Intermediate',
    'Intermediate',
    'Upper-Intermediate',
    'Advanced',
    'Proficient',
    'Expert',
    'Master'
  ];

  @override
  void initState() {
    super.initState();
    _loadUnlockedStage();
  }

  Future<void> _loadUnlockedStage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unlockedStage = prefs.getInt('unlocked_stage') ?? 1;
    });
  }

  Future<void> _selectStage(BuildContext context, String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('league_level', level);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeagueScreen()),
    ).then((_) => _loadUnlockedStage()); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00111C),
      bottomNavigationBar: BottomNavbar(forcedIndex: 0,),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:  Text("Select Your Stage", style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF00111C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: _stages.length,
          itemBuilder: (context, index) {
            final stageName = _stages[index];
            final stageNumber = index + 1;
            final isUnlocked = stageNumber <= _unlockedStage;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                onPressed: isUnlocked
                    ? () => _selectStage(context, stageName)
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  backgroundColor: isUnlocked
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                child: Text(
                  "Stage $stageNumber - ${stageName.toUpperCase()}",
                  style: TextStyle(
                    fontSize: 18,
                    color: isUnlocked ? Colors.white : Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
