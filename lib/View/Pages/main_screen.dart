import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingoverse_frontend/Services/api_client_service.dart';
import 'package:lingoverse_frontend/View/Widgets/buttom_navbar.dart';
import 'package:lingoverse_frontend/View/Widgets/customed_text.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiClientService _api = ApiClientService(baseUrl: 'http://127.0.0.1:8000/api');
  bool _loading = true;

  int bestScore = 0;
  int bestRank = 0;
  String learningRatio = "0.0";

  String _selectedLanguage = "English";
  String _selectedLevel = "Beginner";

  final List<String> _languages = ["English", "Arabic", "French", "Spanish"];
  final List<String> _levels = ["Beginner", "Intermediate", "Fluent"];

  int _trophies = 0;

  Future<void> _loadTrophies() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _trophies = prefs.getInt('trophies') ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettingsAndStats();
    _loadTrophies();
  }

  Future<void> _loadSettingsAndStats() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final lang = prefs.getString('language') ?? 'English';
    final lvl = prefs.getString('level') ?? 'Beginner';

    setState(() {
      _selectedLanguage = _languages.contains(lang) ? lang : "English";
      _selectedLevel = _levels.contains(lvl) ? lvl : "Beginner";
    });

    if (userId == null) return;

    final res = await _api.get('/user-progress/stats/$userId');

    if (res.success) {
      setState(() {
        bestScore = res.data['best_score'] ?? 0;
        bestRank = res.data['best_rank'] ?? 0;
        learningRatio = "${res.data['learning_ratio']}/10";
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('level', _selectedLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(200),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const CustomedText(text: 'Welcome Back', size: 24, weight: FontWeight.w500),
                      const SizedBox(height: 40),
                      _dropdownRow("Language", _languages, _selectedLanguage, (val) {
                        setState(() => _selectedLanguage = val);
                        _saveSettings();
                      }),
                      const SizedBox(height: 20),
                      _dropdownRow("Level", _levels, _selectedLevel, (val) {
                        setState(() => _selectedLevel = val);
                        _saveSettings();
                      }),
                      const SizedBox(height: 20),
                      _infoRow('Trophies Earned:', '$_trophies'),
                      const SizedBox(height: 20),
                      _infoRow('Best Score:', '$bestScore'),
                      const SizedBox(height: 20),
                      _infoRow('Best Rank:', bestRank == 0 ? 'Unranked' : '$bestRank'),
                      const SizedBox(height: 20),
                      _infoRow('Learning Ratio:', learningRatio),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomedText(text: label, size: 20, weight: FontWeight.w400),
        CustomedText(text: value, size: 20, weight: FontWeight.w400),
      ],
    );
  }

  Widget _dropdownRow(String label, List<String> options, String value, Function(String) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomedText(text: label, size: 18, weight: FontWeight.w400),
        DropdownButton<String>(
          value: value,
          dropdownColor: Theme.of(context).primaryColor,
          items: options.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (val) => onChanged(val!),
        ),
      ],
    );
  }
}
