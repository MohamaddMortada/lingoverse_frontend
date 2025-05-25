import 'package:flutter/material.dart';
import 'package:lingoverse_frontend/Model/challenge.dart';
import 'package:lingoverse_frontend/Services/api_client_service.dart';
import 'package:lingoverse_frontend/View/Widgets/buttom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  final ApiClientService _api = ApiClientService(baseUrl: 'http://127.0.0.1:8000/api');
  List<Challenge> _challenges = [];
  List<TextEditingController> _controllers = [];
  List<Map<String, dynamic>> _results = [];
  bool _allSubmitted = false;
  int _totalScore = 0;
  String? _title;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndGenerateChallenges();
  }

  Future<void> _loadUserIdAndGenerateChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    if (id != null) {
      setState(() => _userId = id);
      _generateChallenges();
    }
  }
  

  Future<void> _generateChallenges() async {
    final prefs = await SharedPreferences.getInstance();
final language = prefs.getString('language') ?? 'English';
final level = prefs.getString('level') ?? 'Beginner';

final response = await _api.post('/challenges/generate-ai', {
  "language": language,
  "level": level,
});
    if (response.success) {
      final List challenges = response.data['challenges'];
      setState(() {
        _title = response.data['title'];
        _challenges = challenges.map((e) => Challenge.fromJson(e)).toList();
        _controllers = List.generate(challenges.length, (_) => TextEditingController());
        _results = List.generate(challenges.length, (_) => {});
      });
    }
  }

  Future<void> _submitAnswer(int index) async {
    final userAnswer = _controllers[index].text.trim();
    if (userAnswer.isEmpty || _userId == null) return;

    final body = {
      "user_id": _userId,
      "challenge_id": _challenges[index].id,
      "user_answer": userAnswer,
    };

    final response = await _api.post('/challenges/answer', body);
    if (response.success) {
      setState(() {
        _results[index] = response.data['result'];
      });
    }
  }

  void _submitAll() {
    int total = 0;
    for (var result in _results) {
      total += int.tryParse(result['score'].toString()) ?? 0;
    }
    total = (total / 5) as int;

    setState(() {
      _totalScore = total;
      _allSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    if (_userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      bottomNavigationBar: const BottomNavbar(forcedIndex: 1),
      backgroundColor: const Color(0xFF00131F),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), 
        backgroundColor: const Color(0xFF00111C),
        title: Text("Challenges", style: TextStyle(color: Colors.white),),
      ),
      body: _challenges.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_title != null)
                    Text(
                      _title!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _challenges.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        final isCorrect = result['is_correct'];
                        final feedback = result['feedback'];
                        final score = result['score'];

                        final bgColor = isCorrect == null
                            ? const Color(0xFF1A2B38).withOpacity(0.8)
                            : isCorrect
                                ? Colors.greenAccent.withOpacity(0.2)
                                : Colors.redAccent.withOpacity(0.2);

                        return Card(
                          color: bgColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _challenges[index].description,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _controllers[index],
                                  maxLines: 3,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "Your answer",
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _submitAnswer(index),
                                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                                      child: const Text("Submit"),
                                    ),
                                    if (score != null)
                                      Text(
                                        "Score: $score",
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                  ],
                                ),
                                if (feedback != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      "Feedback: $feedback",
                                      style: const TextStyle(color: Colors.orangeAccent),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _submitAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: const Text("Submit All", style: TextStyle(fontSize: 16)),
                  ),
                  if (_allSubmitted)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        "Total Score: $_totalScore",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
