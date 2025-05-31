import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lingoverse_frontend/Services/auth_service.dart';
import 'package:lingoverse_frontend/View/Pages/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingoverse_frontend/Services/api_client_service.dart';
import 'package:lingoverse_frontend/View/Widgets/buttom_navbar.dart';
import 'package:lingoverse_frontend/View/Widgets/customed_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiClientService _api = ApiClientService(baseUrl: 'http://127.0.0.1:8000/api');

  bool _isEditing = false;
  bool _loading = true;

  int? userId;
  String? imageBase64;
  XFile? selectedImage;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ageController = TextEditingController();

  final AuthService _authService = AuthService();


  String _selectedLanguage = "English";
  String _nativeLanguage = "English";
  String _selectedLevel = "Beginner";
final List<String> _languages = [
  'Afrikaans',
  'Albanian',
  'Amharic',
  'Arabic',
  'Armenian',
  'Assamese',
  'Azerbaijani',
  'Basque',
  'Belarusian',
  'Bengali',
  'Bosnian',
  'Bulgarian',
  'Burmese',
  'Catalan',
  'Cebuano',
  'Chinese (Simplified)',
  'Chinese (Traditional)',
  'Corsican',
  'Croatian',
  'Czech',
  'Danish',
  'Dutch',
  'English',
  'Esperanto',
  'Estonian',
  'Filipino',
  'Finnish',
  'French',
  'Frisian',
  'Galician',
  'Georgian',
  'German',
  'Greek',
  'Gujarati',
  'Haitian Creole',
  'Hausa',
  'Hawaiian',
  'Hebrew',
  'Hindi',
  'Hmong',
  'Hungarian',
  'Icelandic',
  'Igbo',
  'Indonesian',
  'Irish',
  'Italian',
  'Japanese',
  'Javanese',
  'Kannada',
  'Kazakh',
  'Khmer',
  'Kinyarwanda',
  'Korean',
  'Kurdish (Kurmanji)',
  'Kyrgyz',
  'Lao',
  'Latin',
  'Latvian',
  'Lithuanian',
  'Luxembourgish',
  'Macedonian',
  'Malagasy',
  'Malay',
  'Malayalam',
  'Maltese',
  'Maori',
  'Marathi',
  'Mongolian',
  'Nepali',
  'Norwegian',
  'Nyanja (Chichewa)',
  'Odia (Oriya)',
  'Pashto',
  'Persian (Farsi)',
  'Polish',
  'Portuguese',
  'Punjabi',
  'Romanian',
  'Russian',
  'Samoan',
  'Scots Gaelic',
  'Serbian',
  'Sesotho',
  'Shona',
  'Sindhi',
  'Sinhala',
  'Slovak',
  'Slovenian',
  'Somali',
  'Spanish',
  'Sundanese',
  'Swahili',
  'Swedish',
  'Tajik',
  'Tamil',
  'Tatar',
  'Telugu',
  'Thai',
  'Tigrinya',
  'Turkish',
  'Turkmen',
  'Ukrainian',
  'Urdu',
  'Uyghur',
  'Uzbek',
  'Vietnamese',
  'Welsh',
  'Xhosa',
  'Yiddish',
  'Yoruba',
  'Zulu',
];
  final List<String> _levels = ["Beginner", "Intermediate", "Fluent"];

  int _trophies = 0;
  int bestScore = 0;
  int bestRank = 0;
  String learningRatio = "0.0";

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await _loadUser();
    await _loadStats();
    await _loadTrophies();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');
    _selectedLanguage = prefs.getString('language') ?? 'English';
    _selectedLevel = prefs.getString('level') ?? 'Beginner';
    _nativeLanguage = prefs.getString('native') ?? 'English';

    if (userId == null) return;

    final res = await _api.get('/users/$userId');
    if (res.success && res.data != null) {
      final user = res.data;
      setState(() {
        nameController.text = user['name'] ?? '';
        emailController.text = user['email'] ?? '';
        ageController.text = user['age']?.toString() ?? '';
        imageBase64 = user['image'];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    if (id == null) return;

    final res = await _api.get('/user-progress/stats/$id');
    if (res.success && res.data != null) {
      setState(() {
        bestScore = res.data['best_score'] ?? 0;
        bestRank = res.data['best_rank'] ?? 0;
        learningRatio = "${res.data['learning_ratio']}/10";
      });
    }
  }

  Future<void> _loadTrophies() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _trophies = prefs.getInt('trophies') ?? 0;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() {
        selectedImage = img;
        imageBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _updateUser() async {
    if (userId == null) return;

    final body = {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text.isNotEmpty ? passwordController.text : null,
      'age': int.tryParse(ageController.text),
      'image': imageBase64,
    };

    body.removeWhere((key, value) => value == null);

    final res = await _api.put('/users/$userId', body);
    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );
      setState(() {
        _isEditing = false;
        _loading = true;
      });
      await _loadUser();
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('native', _nativeLanguage);
    await prefs.setString('level', _selectedLevel);
  }

Widget _buildDatePickerWithIcon(String label) {
  return TextField(
    controller: ageController,
    readOnly: true,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            final age = DateTime.now().year - picked.year;
            setState(() {
              ageController.text = age.toString();
            });
          }
        },
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      bottomNavigationBar: const BottomNavbar(forcedIndex: 2),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF00111C),
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        actions: [
  IconButton(
    icon: const Icon(Icons.logout, color: Color.fromARGB(255, 255, 1, 1)),
    tooltip: "Logout",
    onPressed: () async {
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF00131F),
          title: const Text("Confirm Logout", style: TextStyle(color: Colors.white)),
          content: const Text("Are you sure you want to log out?", style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );

      if (shouldLogout == true) {
        await _authService.logout();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => RegisterScreen()),
          (route) => false,
        );
      }
    },
  ),
  IconButton(
    icon: Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.white),
    tooltip: "Edit",
    onPressed: () => setState(() => _isEditing = !_isEditing),
  ),
],


      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isEditing ? _pickImage : null,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: imageBase64 != null
                          ? MemoryImage(base64Decode(imageBase64!))
                          : const NetworkImage('https://i.pravatar.cc/150?img=8') as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isEditing
                      ? _buildField("Name", nameController)
                      : _buildDisplayRow("Name", nameController.text),
                  const SizedBox(height: 10),
                  _isEditing
                      ? _buildField("Email", emailController)
                      : _buildDisplayRow("Email", emailController.text),
                  const SizedBox(height: 10),
                 _isEditing
  ? _buildDatePickerWithIcon("Date of Birth")
  : _buildDisplayRow("Age", ageController.text),


                  const SizedBox(height: 10),
                  _isEditing
                      ? _buildField("Password", passwordController, obscureText: true)
                      : _buildDisplayRow("Password", "********"),
                  const SizedBox(height: 30),
                  _dropdownRow("Learning Language", _languages, _selectedLanguage, (val) {
                    setState(() => _selectedLanguage = val);
                    _savePreferences();
                  }),
                  _dropdownRow("Native Language", _languages, _nativeLanguage, (val) {
                    setState(() => _nativeLanguage = val);
                    _savePreferences();
                  }),
                  const SizedBox(height: 20),
                  _dropdownRow("Level", _levels, _selectedLevel, (val) {
                    setState(() => _selectedLevel = val);
                    _savePreferences();
                  }),
                  const SizedBox(height: 30),
                  _infoRow('Trophies Earned:', '$_trophies'),
                  const SizedBox(height: 10),
                  _infoRow('Best Score:', '$bestScore'),
                  const SizedBox(height: 10),
                  _infoRow('Best Rank:', bestRank == 0 ? 'Unranked' : '$bestRank'),
                  const SizedBox(height: 10),
                  _infoRow('Learning Ratio:', learningRatio),
                  const SizedBox(height: 30),
                  if (_isEditing)
                    ElevatedButton(
                      onPressed: _updateUser,
                      child: const Text("Save"),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType? keyboardType, bool obscureText = false}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDisplayRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomedText(text: '$label:', size: 16, weight: FontWeight.w500),
        CustomedText(text: value, size: 16, weight: FontWeight.w500),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomedText(text: label, size: 18, weight: FontWeight.w400),
        CustomedText(text: value, size: 18, weight: FontWeight.w400),
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
