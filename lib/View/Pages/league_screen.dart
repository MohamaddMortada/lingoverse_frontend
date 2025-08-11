import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lingoverse_frontend/Model/challenge.dart';
import 'package:lingoverse_frontend/Services/api_client_service.dart';
import 'package:lingoverse_frontend/View/Widgets/buttom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class LeagueScreen extends StatefulWidget {
  const LeagueScreen({Key? key}) : super(key: key);

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen>
    with SingleTickerProviderStateMixin {
  final ApiClientService _api = ApiClientService(
    baseUrl: 'http://127.0.0.1:8000/api',
  );
  List<Challenge> _challenges = [];
  List<Map<String, dynamic>> _results = [];
  String? _title;
  int? _userId;
  int _unlockedStage = 1;

  late AnimationController _trophyController;
  late Animation<double> _trophyScale;
  late Animation<double> _trophyOpacity;

  final List<String> _stageNames = [
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
    _trophyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _trophyScale = Tween<double>(begin: 1.0, end: 1.2).animate(_trophyController);
    _trophyOpacity = Tween<double>(begin: 0.7, end: 1.0).animate(_trophyController);
    _init();
  }

  @override
  void dispose() {
    _trophyController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final currentStageName = prefs.getString('league_level');
    print('currentStageName: $currentStageName');

    final id = prefs.getInt('user_id');
    final   _language = prefs.getString('language')?.toLowerCase();
    print("_language: $_language");
    if (id != null) {
      setState(() => _userId = id);
      _unlockedStage = prefs.getInt('unlocked_stage') ?? 1;
      await _generateChallenges();
    }
  }

  Future<void> _generateChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final level = prefs.getString('league_level') ?? 'Beginner';
    final language = prefs.getString('language') ?? 'english';
    final native = prefs.getString('native') ?? 'english';

    final response = await _api.post('/challenges/generate-ai', {
      "language": language,
      "native": native,
      "level": level,
    });

    if (response.success) {
      final List raw = response.data['challenges'];
      setState(() {
        _title = response.data['title'];
        _challenges = raw.map((e) => Challenge.fromJson(e)).toList();
        _results = List.generate(raw.length, (_) => {});
      });
    }
  }

  Future<void> _submitAnswer(int index) async {
    final controller = TextEditingController();
    Color? resultColor;
    bool? isCorrect;
    String? feedback;
    Map<String, dynamic>? finalResult;

    final prefs = await SharedPreferences.getInstance();
    final native = prefs.getString('native') ?? 'english';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> handleSubmit() async {
              final answer = controller.text.trim();
              if (answer.isEmpty || _userId == null) return;

              final body = {
                "user_id": _userId,
                "language": native,
                "challenge_id": _challenges[index].id,
                "user_answer": answer,
              };

              final res = await _api.post('/challenges/answer', body);
              if (res.success) {
                final result = res.data['result'];
                isCorrect = result['is_correct'];
                resultColor = isCorrect! ? Colors.green : Colors.red;
                feedback = isCorrect! ? 'Correct!' : 'Wrong. Try again.';
                finalResult = result;

                setState(() {});

                if (isCorrect!) {
                  await Future.delayed(const Duration(seconds: 1));
                  Navigator.pop(context);
                }
              }
            }

            return AlertDialog(
              title: Text('challenge_number'.tr(namedArgs: {'index': '$index'})),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_challenges[index].description),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'your_answer'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => handleSubmit(),
                  ),
                  if (feedback != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: resultColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCorrect! ? Icons.check_circle : Icons.cancel,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(feedback ?? '', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: handleSubmit,
                  child: Text(isCorrect == null ? 'submit'.tr() : 'submit_again'.tr()),
                ),
              ],
            );
          },
        );
      },
    );

    if (finalResult != null && finalResult!['is_correct'] == true) {
      setState(() {
        _results[index] = finalResult!;
      });

      if (_allCompleted()) {
        _trophyController.repeat(reverse: true);
        await _addTrophy();
        await _unlockNextStage();
      }
    }
  }

  Future<void> _addTrophy() async {
    final prefs = await SharedPreferences.getInstance();
    int trophies = prefs.getInt('trophies') ?? 0;
    await prefs.setInt('trophies', trophies + 1);
  }

  Future<void> _unlockNextStage() async {
  final prefs = await SharedPreferences.getInstance();
  final currentStageName = prefs.getString('league_level');
  
  final currentStageIndex = _stageNames.indexOf(currentStageName ?? '');
  int unlockedStage = prefs.getInt('unlocked_stage') ?? 1;

  final userId = prefs.getInt('user_id');
  final language = prefs.getString('language')?.toLowerCase() ?? 'english';

print('currentStageName: $currentStageName');
print('currentStageIndex: $currentStageIndex');
print('unlockedStage: $unlockedStage');
print('Expected unlockedStage: ${currentStageIndex + 1}');
print('All completed: ${_allCompleted()}');
print('UserId: $userId');

 if (_allCompleted()) {
    print('Condition met. Sending update-level request...');
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/users/$userId/update-level'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'level_type': '${language}_level',
        }),
      );

      print('Response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        await prefs.setInt('unlocked_stage', unlockedStage + 1);
        setState(() {
          _unlockedStage = unlockedStage + 1;
        });
        print('Unlocked stage updated to ${unlockedStage + 1}');
      } else {
        print('Failed to update level on server: ${response.body}');
      }
    } catch (e) {
      print('Error updating level: $e');
    }
  } else {
    print('Condition not met, skipping update-level call');
  }
}


  bool _isActive(int index) {
    if (index == 0) return true;
    return _results[index - 1]['is_correct'] == true;
  }

  bool _isCompleted(int index) {
    return _results[index]['is_correct'] == true;
  }

  bool _allCompleted() {
    return _results.length == _challenges.length &&
        _results.every((r) => r['is_correct'] == true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00111C),
      bottomNavigationBar: const BottomNavbar(forcedIndex: 0),
      body: _challenges.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          )),
                      Text(
                        _title ?? 'league'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: _challenges.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _challenges.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: _allCompleted()
                                  ? AnimatedBuilder(
                                      animation: _trophyController,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _trophyScale.value,
                                          child: Opacity(
                                            opacity: _trophyOpacity.value,
                                            child: const TrophyWidget(),
                                          ),
                                        );
                                      },
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          );
                        }

                        final isActive = _isActive(index);
                        final isCompleted = _isCompleted(index);

                        return GestureDetector(
                          onTap: isActive ? () => _submitAnswer(index) : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Colors.green.withOpacity(0.2)
                                  : isActive
                                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                              border: Border.all(
                                color: isCompleted
                                    ? Colors.green
                                    : isActive
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isCompleted
                                      ? Icons.check_circle
                                      : isActive
                                          ? Icons.play_circle_fill
                                          : Icons.lock,
                                  color: isCompleted
                                      ? Colors.green
                                      : isActive
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'challenge_number'.tr(namedArgs: {'index': '$index'}),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                if (isCompleted)
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class TrophyWidget extends StatelessWidget {
  const TrophyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.emoji_events,
          size: 64,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          'trophy_earned'.tr(),
          style: const TextStyle(
            color: Colors.amberAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
