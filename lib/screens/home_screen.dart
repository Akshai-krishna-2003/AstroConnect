import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/localization_service.dart';
import 'login_screen.dart';
import 'astrology_input_screen.dart';
import 'partner_compatibility_screen.dart';
import 'previous_searches_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String username = "User"; // Default username
  String _welcomeMessage = "Loading...";
  List<String> _languageCodes = ['en', 'ml', 'ta', 'hi']; // Language rotation
  int _currentLanguageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  void _loadUserDetails() async {
    var user = await _authService.getUserDetails();
    if (user != null) {
      setState(() {
        username = user["username"]; // Correctly fetching username
      });

      // Now start rotating languages after setting username
      _startLanguageRotation();
    }
  }

  void _startLanguageRotation() {
    _updateWelcomeMessage(); // Initial update

    _timer = Timer.periodic(Duration(seconds: 20), (timer) {
      setState(() {
        _currentLanguageIndex =
            (_currentLanguageIndex + 1) % _languageCodes.length;
      });

      _updateWelcomeMessage();
    });
  }

  void _updateWelcomeMessage() async {
    String langCode = _languageCodes[_currentLanguageIndex];
    Map<String, String> translations = await LocalizationService.loadLanguage(
      langCode,
    );

    if (mounted) {
      setState(() {
        _welcomeMessage = translations["welcome"]!.replaceAll(
          "{username}",
          username,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: Duration(milliseconds: 500), // Smooth transition effect
          child: Text(_welcomeMessage, key: ValueKey<String>(_welcomeMessage)),
        ),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logout)],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AstrologyInputScreen(),
                  ),
                );
              },
              child: Text("🔮 See Your Future"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PartnerCompatibilityScreen(),
                  ),
                );
              },
              child: Text("💑 Find Your Match"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviousSearchesScreen(),
                  ),
                );
              },
              child: Text("📜 Previous Searches"),
            ),
          ],
        ),
      ),
    );
  }
}
