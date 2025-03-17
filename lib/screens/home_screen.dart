import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/localization_service.dart';
import 'login_screen.dart';
import 'astrology_input_screen.dart';
import 'partner_compatibility_screen.dart';
import 'previous_searches_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
        username = user["username"];
      });

      // Now start rotating languages after setting username
      _startLanguageRotation();
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse(
      'https://sites.google.com/view/privacy-policy-astro-connect/home',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
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
      body: Stack(
        children: [
          // **Background Image**
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/astrology_background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // **Logout Button (Top Right)**
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.white, size: 28),
              onPressed: _logout,
            ),
          ),

          // This is like i button for privacy policy I made using google sites
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.info, color: Colors.white70, size: 28),
              onPressed: _launchPrivacyPolicy,
            ),
          ),

          // **Content Layout**
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),

              // **Welcome Message**
              Center(
                child: Text(
                  _welcomeMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.purpleAccent,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // **Buttons Section**
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAstroButton(
                        "🔮 See Your Future",
                        "assets/crystal_ball.png",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AstrologyInputScreen(),
                            ),
                          );
                        },
                      ),
                      _buildAstroButton(
                        "💑 Find Your Match",
                        "assets/love_aura.png",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PartnerCompatibilityScreen(),
                            ),
                          );
                        },
                      ),
                      _buildAstroButton(
                        "📜 Previous Searches",
                        "assets/scroll.png",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PreviousSearchesScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // **Custom Button Builder**
  Widget _buildAstroButton(String text, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height / 4, // Adjusted size
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.contain,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.withOpacity(0.7),
              Colors.blueAccent.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 5,
                  color: Colors.black45,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
