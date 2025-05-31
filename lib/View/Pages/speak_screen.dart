import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lingoverse_frontend/Services/api_client_service.dart';
import 'package:lingoverse_frontend/View/Widgets/buttom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lingoverse_frontend/View/Widgets/customed_text.dart';

class SpeakScreen extends StatefulWidget {
  const SpeakScreen({super.key});

  @override
  State<SpeakScreen> createState() => _SpeakScreenState();
}

class _SpeakScreenState extends State<SpeakScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ApiClientService _api = ApiClientService(baseUrl: 'http://127.0.0.1:8000/api');

  final List<_Message> _messages = [];
  bool _isListening = false;
  bool _speechAvailable = false;
  String _spokenText = '';
  String _language = 'English';
  int? _userId;
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



  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _initSpeech();
  }

  Future<void> _loadLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
     _userId = prefs.getInt('user_id');
    _language = prefs.getString('language') ?? 'English';
  });
}

  Future<void> _initSpeech() async {
    if (kIsWeb) {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening') {
            _speech.stop();
            _sendToAI(_spokenText);
            setState(() => _isListening = false);
          }
        },
        onError: (error) => print("Error: $error"),
      );
      setState(() => _speechAvailable = available);
    }
  }

  void _startListening() {
  if (!_speechAvailable) return;

  setState(() {
    _isListening = true;
    _spokenText = '';
  });

  final selectedLocale = _languageLocales[_language] ?? 'en-US';

  _speech.listen(
    onResult: (result) {
      setState(() {
        _spokenText = result.recognizedWords;
      });
    },
    localeId: selectedLocale, 
  );
}


  Future<void> _sendToAI(String text) async {
  if (text.trim().isEmpty) return;

  setState(() {
    _messages.add(_Message(text: text, isUser: true));
  });
  _scrollToBottom();

  final res = await _api.post('/speech/chat', {
    'message': text,
    'user_id': _userId, 
    'language': _language,
  });

  final aiReply = res.success && res.data['reply'] != null
      ? res.data['reply']
      : "Sorry, I couldn't understand that.";

  setState(() {
    _messages.add(_Message(text: aiReply, isUser: false));
  });
  _scrollToBottom();
}


  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), 
        backgroundColor: const Color(0xFF00111C),
        title: Text("AI ChatBot", style: TextStyle(color: Colors.white),),
      ),
        bottomNavigationBar: const BottomNavbar(forcedIndex: 1),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              //CustomedText(text: 'AI ChatBot', size: 24, weight: FontWeight.bold),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: msg.isUser
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(msg.isUser ? 16 : 0),
                            bottomRight: Radius.circular(msg.isUser ? 0 : 16),
                          ),
                        ),
                        child: CustomedText(
                          text: msg.text,
                          size: 16,
                          weight: FontWeight.w400,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              IconButton(
                icon: Icon(
                  _isListening ? Icons.stop_circle : Icons.mic,
                  color: Colors.white,
                  size: 50,
                ),
                onPressed: _isListening ? _speech.stop : _startListening,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  _Message({required this.text, required this.isUser});
}
