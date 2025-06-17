import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lingoverse_frontend/View/Pages/register_screen.dart';
import 'package:lingoverse_frontend/View/Pages/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('fr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MainApp(),
    ),
  );
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    return userId != null ? const SplashScreen() : RegisterScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  theme: ThemeData(
    scaffoldBackgroundColor: const Color(0xFF00131F),
    primaryColor: const Color(0xFf25C0FF),
  ),
  localizationsDelegates: context.localizationDelegates,
  supportedLocales: context.supportedLocales,
  locale: context.locale,
  home: FutureBuilder<Widget>(
    future: _getInitialScreen(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return snapshot.data!;
      }
    },
  ),
);
  }
}
