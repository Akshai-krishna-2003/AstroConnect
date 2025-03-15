import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
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

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user != null && user.emailVerified) {
            return HomeScreen();
          }
          return LoginScreen();
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
