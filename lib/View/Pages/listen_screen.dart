import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lingoverse_frontend/Services/api_client_service.dart';
import 'package:lingoverse_frontend/View/Widgets/buttom_navbar.dart';
import 'package:lingoverse_frontend/View/Widgets/button.dart';
import 'package:lingoverse_frontend/View/Widgets/customed_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class ListenScreen extends StatefulWidget {
  const ListenScreen({super.key});

  @override
  State<ListenScreen> createState() => _ListenScreenState();
}

class _ListenScreenState extends State<ListenScreen> {
  final FlutterTts _tts = FlutterTts();
  final ApiClientService _api =
      ApiClientService(baseUrl: 'http://127.0.0.1:8000/api');
  final TextEditingController _typedController = TextEditingController();

  String _paragraph = '';
  String _feedback = '';
  int _score = 0;
  String _language = 'English';
  List<String> _missedWords = [];

  bool _isLoading = false;
  bool _isPlaying = false;

  final Map<String, String> _languageLocales = {
    'English': 'en-US',
    'Arabic': 'ar-SA',
    'French': 'fr-FR',
  };

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadLanguage();
    await _setupTts();
    await _fetchParagraph();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _setupTts() async {
  final langCode = switch (_language) {
    'Arabic' => 'ar',
    'French' => 'fr',
    'English' => 'en',
    _ => 'en',
  };

  final voices = await _tts.getVoices;

  final selectedVoice = voices.firstWhere(
    (voice) => voice['locale'].toString().startsWith(langCode),
    orElse: () => null,
  );

  if (selectedVoice != null) {
    await _tts.setVoice({
      'name': selectedVoice['name'],
      'locale': selectedVoice['locale'],
    });
    debugPrint('Voice set: ${selectedVoice['name']} - ${selectedVoice['locale']}');
  } else {
    final fallbackLocale = {'en': 'en-US', 'fr': 'fr-FR', 'ar': 'ar-SA'}[langCode]!;
    final success = await _tts.setLanguage(fallbackLocale);
    debugPrint('Voice not found, using fallback language: $fallbackLocale');
    if (!success) {
      debugPrint('TTS does not support $fallbackLocale on this device.');
    }
  }

  await _tts.setSpeechRate(0.5);

  _tts.setStartHandler(() => setState(() => _isPlaying = true));
  _tts.setCompletionHandler(() => setState(() => _isPlaying = false));
  _tts.setPauseHandler(() => setState(() => _isPlaying = false));
}


  Future<void> _fetchParagraph() async {
    final res = await _api.post('/speech/paragraph', {
      'language': _language,
    });

    if (res.success && res.data['paragraph'] != null) {
      setState(() {
        _paragraph = res.data['paragraph'];
      });
    }
  }

  Future<void> _speak() async {
    await _tts.speak(_paragraph);
  }

  Future<void> _pause() async {
    await _tts.pause();
  }

  Future<void> _analyzeTypedAnswer() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 1;

    final res = await _api.post('/speech/analyze-fluency', {
      'user_id': userId,
      'expected_text': _paragraph,
      'spoken_text': _typedController.text,
    });

    if (res.success && res.data['score'] != null) {
      final rawFeedback = res.data['feedback'];
      setState(() {
        _score = int.tryParse(res.data['score'].toString()) ?? 0;
        _feedback = 'you_missed_words'
            .tr(namedArgs: {'count': '${rawFeedback['missed_words'].length}'});
        _missedWords = List<String>.from(rawFeedback['missed_words']);
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF00111C),
        title: Text('listening'.tr(), style: const TextStyle(color: Colors.white)),
      ),
      bottomNavigationBar: const BottomNavbar(forcedIndex: 1),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            if (!_isPlaying)
              IconButton(
                icon: const Icon(Icons.play_arrow, size: 60, color: Colors.white),
                onPressed: _paragraph.isEmpty ? null : _speak,
              )
            else
              IconButton(
                icon: const Icon(Icons.pause, size: 60, color: Colors.white),
                onPressed: _pause,
              ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _typedController,
                maxLines: null,
                expands: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'type_what_you_heard'.tr(),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomedButton(text: 'submit'.tr(), ontap: _analyzeTypedAnswer),
            const SizedBox(height: 20),
            if (_score >= 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomedText(
                    text: 'score'.tr(),
                    size: 16,
                    weight: FontWeight.w500,
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      Container(
                        height: 30,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF003247),
                          borderRadius: BorderRadius.circular(45),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: 30,
                        width: MediaQuery.of(context).size.width * (_score / 100),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00FFF6), Color(0xFF00A5E7)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(45),
                        ),
                        child: Center(
                          child: CustomedText(
                            text: '$_score%',
                            size: 14,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_feedback.isNotEmpty)
                    CustomedText(
                      text: _feedback,
                      size: 14,
                      weight: FontWeight.w300,
                    ),
                  if (_missedWords.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: CustomedText(
                        text: "missed_words".tr(
                          namedArgs: {'words': _missedWords.join(', ')},
                        ),
                        size: 14,
                        weight: FontWeight.w300,
                      ),
                    ),
                ],
              ),
            if (_isLoading) const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
