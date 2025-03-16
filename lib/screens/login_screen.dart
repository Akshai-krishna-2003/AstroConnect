import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  void _authenticate() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String fullName = _fullNameController.text.trim();
    String username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please enter email and password");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? result;
    if (_isLogin) {
      result = await _authService.login(email, password);
    } else {
      if (fullName.isEmpty || username.isEmpty) {
        _showMessage("Please enter your full name and username.");
        setState(() {
          _isLoading = false;
        });
        return;
      }
      result = await _authService.signUp(email, password, fullName, username);
    }

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      _showMessage(result);
      if (!_isLogin) {
        setState(() {
          _isLogin = true;
        });
      }
    }
  }

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    String? result = await _authService.signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      _showMessage(result);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showForgotPasswordDialog() {
    TextEditingController _forgotEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reset Password"),
          content: TextField(
            controller: _forgotEmailController,
            decoration: InputDecoration(
              labelText: "Enter your email",
              prefixIcon: Icon(Icons.email),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String email = _forgotEmailController.text.trim();
                if (email.isEmpty) {
                  _showMessage("Please enter your email.");
                  return;
                }

                String? result = await _authService.resetPassword(email);
                _showMessage(result ?? "Password reset email sent!");
                Navigator.pop(context);
              },
              child: Text("Send"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/stars_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Centered Form with Overlay
          Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 50),

                    // Title - AstroConnect (Refined positioning)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/astrology_icon.png",
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "AstroConnect",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 12,
                                color: Colors.purpleAccent,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 35),

                    // Toggle Login/Sign-up
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 30,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _isLogin = true),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 18,
                                color:
                                    _isLogin
                                        ? Colors.cyanAccent
                                        : Colors.white70,
                                fontWeight:
                                    _isLogin
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          GestureDetector(
                            onTap: () => setState(() => _isLogin = false),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 18,
                                color:
                                    !_isLogin
                                        ? Colors.cyanAccent
                                        : Colors.white70,
                                fontWeight:
                                    !_isLogin
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 25),

                    if (!_isLogin)
                      _buildTextField("Full Name", _fullNameController),
                    if (!_isLogin)
                      _buildTextField("Username", _usernameController),

                    _buildTextField("Email", _emailController),
                    _buildTextField(
                      "Password",
                      _passwordController,
                      obscureText: true,
                    ),

                    SizedBox(height: 20),

                    // Authentication Button
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                          onPressed: _authenticate,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 80,
                            ),
                            backgroundColor: Colors.deepPurpleAccent,
                          ),
                          child: Text(_isLogin ? "Login" : "Sign Up"),
                        ),

                    SizedBox(height: 20),

                    // Centered Forgot Password
                    if (_isLogin)
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: _showForgotPasswordDialog,
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.cyanAccent),
                          ),
                        ),
                      ),

                    if (!_isLogin)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isLogin = true;
                              });
                            },
                            child: Text(
                              "Already have an account? Login",
                              style: TextStyle(color: Colors.orangeAccent),
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 20),

                    // Sign in with Google (Smaller Logo)
                    Text("or", style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 10),

                    GestureDetector(
                      onTap: _signInWithGoogle,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          "assets/google_logo.png",
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.cyanAccent),
          fillColor: Colors.white.withOpacity(0.2),
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyanAccent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70, width: 1),
          ),
        ),
      ),
    );
  }
}
