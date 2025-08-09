import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/localization_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _requestPermissions();

  runApp(MyApp());
}

Future<void> _requestPermissions() async {
  await [Permission.camera, Permission.storage, Permission.photos].request();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = LocalizationService.defaultLocale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  void _loadLocale() async {
    Locale savedLocale = await LocalizationService.getSavedLocale();
    setState(() {
      _locale = savedLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astrology App',
      theme: ThemeData.dark(),
      home: AuthWrapper(),
      locale: _locale,
      supportedLocales: LocalizationService.supportedLocales,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
