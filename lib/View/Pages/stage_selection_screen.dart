import 'package:flutter/material.dart';
import 'package:lingoverse_frontend/View/Widgets/buttom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'league_screen.dart';

class StageSelectionScreen extends StatefulWidget {
  const StageSelectionScreen({super.key});

  @override
  State<StageSelectionScreen> createState() => _StageSelectionScreenState();
}

class _StageSelectionScreenState extends State<StageSelectionScreen> {
  int _unlockedStage = 1;
  String _language = 'english';
  String native = 'english';

  final List<String> _stages = [
    'beginner',
    'basic',
    'elementary',
    'pre_intermediate',
    'intermediate',
    'upper_intermediate',
    'advanced',
    'proficient',
    'expert',
    'master',
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
      _language = prefs.getString('language') ?? 'English';
      native = prefs.getString('native') ?? 'English';
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
      bottomNavigationBar: const BottomNavbar(forcedIndex: 0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "select_stage".tr(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00111C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: _stages.length,
          itemBuilder: (context, index) {
            final stageKey = _stages[index];
            final stageNumber = index + 1;
            final isUnlocked = stageNumber <= _unlockedStage;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                onPressed:
                    isUnlocked ? () => _selectStage(context, stageKey) : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  backgroundColor:
                      isUnlocked
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                child: Text(
                  stageKey.tr(),
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
