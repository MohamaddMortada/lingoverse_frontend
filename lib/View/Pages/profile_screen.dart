import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lingoverse_frontend/Services/auth_service.dart';
import 'package:lingoverse_frontend/View/Pages/register_screen.dart';
import 'package:lingoverse_frontend/View/Widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingoverse_frontend/Services/api_client_service.dart';
import 'package:lingoverse_frontend/View/Widgets/buttom_navbar.dart';
import 'package:lingoverse_frontend/View/Widgets/customed_text.dart';
import 'package:easy_localization/easy_localization.dart';

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

  final List<String> _languages = ['Arabic', 'English', 'French'];
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
    }..removeWhere((key, value) => value == null);

    final res = await _api.put('/users/$userId', body);
    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("profile_updated".tr())),
      );
      setState(() {
        _isEditing = false;
        _loading = true;
      });
      await _loadUser();
    }
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isError = false;
    String errorMessage = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("change_password".tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "old_password".tr()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "new_password".tr()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "confirm_password".tr()),
              ),
              if (isError) ...[
                const SizedBox(height: 10),
                Text(errorMessage, style: const TextStyle(color: Colors.red)),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("cancel".tr()),
            ),
            TextButton(
              onPressed: () async {
                final oldPass = oldPasswordController.text;
                final newPass = newPasswordController.text;
                final confirmPass = confirmPasswordController.text;

                if (newPass != confirmPass) {
                  setState(() {
                    isError = true;
                    errorMessage = "passwords_do_not_match".tr();
                  });
                  return;
                }

                final res = await _api.post('/users/verify-password', {
                  "user_id": userId,
                  "password": oldPass,
                });

                if (!res.success || res.data['valid'] != true) {
                  setState(() {
                    isError = true;
                    errorMessage = "incorrect_old_password".tr();
                  });
                  return;
                }

                final updateRes = await _api.put('/users/$userId', {
                  "password": newPass,
                });

                if (updateRes.success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("password_updated".tr())),
                  );
                } else {
                  setState(() {
                    isError = true;
                    errorMessage = "update_failed".tr();
                  });
                }
              },
              child: Text("save".tr()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('native', _nativeLanguage);
    await prefs.setString('level', _selectedLevel);
  }

  void _changeLanguage(String selectedLanguage) {
    Locale newLocale;
    switch (selectedLanguage.toLowerCase()) {
      case 'arabic':
        newLocale = const Locale('ar');
        break;
      case 'french':
        newLocale = const Locale('fr');
        break;
      default:
        newLocale = const Locale('en');
    }
    context.setLocale(newLocale);
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
        CustomedText(text: '${label.tr()}:', size: 16, weight: FontWeight.w500),
        CustomedText(text: value.tr(), size: 16, weight: FontWeight.w500),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomedText(text: label.tr(), size: 18, weight: FontWeight.w400),
        CustomedText(text: value.tr(), size: 18, weight: FontWeight.w400),
      ],
    );
  }

  Widget _dropdownRow(String label, List<String> options, String value, Function(String) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomedText(text: label.tr(), size: 18, weight: FontWeight.w400),
        DropdownButton<String>(
          value: value,
          dropdownColor: Theme.of(context).primaryColor,
          items: options.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val.tr(), style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (val) => onChanged(val!),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavbar(forcedIndex: 2),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF00111C),
        title: Text("profile".tr(), style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color.fromARGB(255, 255, 1, 1)),
            tooltip: "logout".tr(),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF00131F),
                  title: Text("confirm_logout".tr(), style: const TextStyle(color: Colors.white)),
                  content: Text("logout_confirmation".tr(), style: const TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      child: Text("cancel".tr(), style: const TextStyle(color: Colors.white)),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: Text("logout".tr(), style: const TextStyle(color: Colors.redAccent)),
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
            tooltip: "edit".tr(),
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
                      ? _buildField("name".tr(), nameController)
                      : _buildDisplayRow("name", nameController.text),
                  const SizedBox(height: 10),
                  _isEditing
                      ? _buildField("email".tr(), emailController)
                      : _buildDisplayRow("email", emailController.text),
                  const SizedBox(height: 10),
                  _isEditing
                      ? _buildField("date_of_birth".tr(), ageController)
                      : _buildDisplayRow("age", ageController.text),
                  const SizedBox(height: 10),
                  if (_isEditing)
                  CustomedButton(text: "change_password".tr(), ontap: _showChangePasswordDialog),
                   
                  const SizedBox(height: 30),
                  _dropdownRow("learning_language", _languages, _selectedLanguage, (val) {
                    setState(() => _selectedLanguage = val);
                    _savePreferences();
                  }),
                  _dropdownRow("native_language", _languages, _nativeLanguage, (val) {
                    setState(() => _nativeLanguage = val);
                    _savePreferences();
                    _changeLanguage(val);
                  }),
                  const SizedBox(height: 20),
                  _dropdownRow("level", _levels, _selectedLevel, (val) {
                    setState(() => _selectedLevel = val);
                    _savePreferences();
                  }),
                  const SizedBox(height: 30),
                  _infoRow('trophies_earned', '$_trophies'),
                  const SizedBox(height: 10),
                  _infoRow('best_score', '$bestScore'),
                  const SizedBox(height: 10),
                  _infoRow('best_rank', bestRank == 0 ? 'Unranked' : '$bestRank'),
                  const SizedBox(height: 10),
                  _infoRow('learning_ratio', learningRatio),
                  const SizedBox(height: 30),
                  if (_isEditing)
                    ElevatedButton(
                      onPressed: _updateUser,
                      child: Text("save".tr()),
                    ),
                ],
              ),
            ),
    );
  }
}
