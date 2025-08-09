import 'package:astro_app/screens/home_screen.dart';
import 'package:astro_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        // Reload user to get latest verification status
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
      }

      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _currentUser != null && _currentUser!.emailVerified
        ? HomeScreen()
        : LoginScreen();
  }
}
