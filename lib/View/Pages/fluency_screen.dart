import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lingoverse_frontend/Services/api_client_service.dart';
import 'package:lingoverse_frontend/View/Widgets/buttom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lingoverse_frontend/View/Widgets/customed_text.dart';
import 'dart:convert';

class FluencyScreen extends StatefulWidget {
  const FluencyScreen({super.key});

  @override
  State<FluencyScreen> createState() => _FluencyScreenState();
}

class _FluencyScreenState extends State<FluencyScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ApiClientService _api = ApiClientService(
    baseUrl: 'http://127.0.0.1:8000/api',
  );

  bool _isListening = false;
  bool _speechAvailable = false;
  String _spokenText = '';
  String _status = '';
  String _paragraph = '';
  String _feedbackText = '';
  int _score = 0;
  String _language = 'English';
  List<String> _missedWords = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadLanguage();
    await _initSpeech();
    await _fetchParagraph();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _language = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _initSpeech() async {
    if (kIsWeb) {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          setState(() => _status = status);
          onStatus: (status) {
  if (!mounted) return;
  setState(() => _status = status);
};
        },
        onError: (error) => print("Speech error: $error"),
      );
      if (!mounted) return;
      setState(() => _speechAvailable = available);
    }
  }

  Future<void> _fetchParagraph() async {
    final res = await _api.post('/speech/paragraph', {
      'language': _language,
    });
    if (!mounted) return;
    if (res.success && res.data['paragraph'] != null) {
      setState(() {
        _paragraph = res.data['paragraph'];
        print("Sending language: $_language");
        print(_paragraph);
      });
    }
  }

  void _startListening() {
    if (!_speechAvailable) return;

    final localeId = _getLocaleForLanguage(_language);

    setState(() {
      _isListening = true;
      _spokenText = '';
      _feedbackText = '';
      _score = 0;
    });

    _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _spokenText = result.recognizedWords;
          print("Recognized: $_spokenText");
        });
      },
      localeId: localeId,
    );
  }

final Map<String, String> _languageLocales = {
  'Afrikaans': 'af-ZA',
  'Arabic': 'ar-SA',
  'Basque': 'eu-ES',
  'Bulgarian': 'bg-BG',
  'Catalan': 'ca-ES',
  'Chinese (Simplified)': 'zh-CN',
  'Chinese (Traditional)': 'zh-TW',
  'Croatian': 'hr-HR',
  'Czech': 'cs-CZ',
  'Danish': 'da-DK',
  'Dutch': 'nl-NL',
  'English': 'en-US',
  'Finnish': 'fi-FI',
  'French': 'fr-FR',
  'Galician': 'gl-ES',
  'German': 'de-DE',
  'Greek': 'el-GR',
  'Hebrew': 'he-IL',
  'Hindi': 'hi-IN',
  'Hungarian': 'hu-HU',
  'Icelandic': 'is-IS',
  'Indonesian': 'id-ID',
  'Italian': 'it-IT',
  'Japanese': 'ja-JP',
  'Korean': 'ko-KR',
  'Latvian': 'lv-LV',
  'Lithuanian': 'lt-LT',
  'Malay': 'ms-MY',
  'Norwegian': 'no-NO',
  'Polish': 'pl-PL',
  'Portuguese': 'pt-PT',
  'Romanian': 'ro-RO',
  'Russian': 'ru-RU',
  'Serbian': 'sr-RS',
  'Slovak': 'sk-SK',
  'Slovenian': 'sl-SI',
  'Spanish': 'es-ES',
  'Swahili': 'sw-KE',
  'Swedish': 'sv-SE',
  'Tamil': 'ta-IN',
  'Thai': 'th-TH',
  'Turkish': 'tr-TR',
  'Ukrainian': 'uk-UA',
  'Vietnamese': 'vi-VN',
  'Zulu': 'zu-ZA',
};

String _getLocaleForLanguage(String language) {
  return _languageLocales[language] ?? 'en-US';
}


  Future<void> _analyzeFluency() async {
  if (_paragraph.isEmpty || _spokenText.isEmpty) return;

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id') ?? 6;

  final body = {
    'user_id': userId,
    'expected_text': _paragraph,
    'spoken_text': _spokenText,
  };

  final res = await _api.post('/speech/analyze-fluency', body);
  print("Response from /analyze-fluency: ${res.data}");

  if (!mounted) return;
  if (res.success && res.data != null) {
    final rawFeedback = res.data['feedback'];
    final List<String> missed = rawFeedback['missed_words'] != null
        ? List<String>.from(rawFeedback['missed_words'])
        : [];

    setState(() {
      _score = int.tryParse(res.data['score'].toString()) ?? 0;
      _feedbackText = "You missed ${missed.length} word(s).";
      _missedWords = missed;
    });
  }
}


  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    if (!kIsWeb) {
      return const Scaffold(
        body: Center(
          child: Text("This feature is only available on Web."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF00111C),
        title: const Text("Fluency Analysis", style: TextStyle(color: Colors.white)),
      ),
      bottomNavigationBar: const BottomNavbar(forcedIndex: 1),
      backgroundColor: const Color(0xFF00131F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                color: const Color(0xFF003247),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: CustomedText(
                  text: _paragraph.isEmpty ? 'Loading paragraph...' : _paragraph,
                  size: 18,
                  weight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: Icon(
                _isListening ? Icons.stop_circle : Icons.mic,
                color: primaryColor,
                size: 50,
              ),
onPressed: () async {
  if (_isListening) {
    await _speech.stop();                
    if (mounted) setState(() => _isListening = false);
    await _analyzeFluency();           
  } else {
    _startListening();                 
  }
},

            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomedText(
                  text: 'Fluency Score:',
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
                if (_feedbackText.isNotEmpty)
                  CustomedText(
                    text: _feedbackText,
                    size: 14,
                    weight: FontWeight.w300,
                  ),
                if (_missedWords.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: CustomedText(
                      text: "Missed: ${_missedWords.join(', ')}",
                      size: 14,
                      weight: FontWeight.w300,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
