import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Listen to auth state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Sign Up with Email & Password
  Future<String?> signUp(
    String email,
    String password,
    String fullName,
    String username,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Send Email Verification
      await userCredential.user?.sendEmailVerification();

      // Save user details to Firestore
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "fullName": fullName,
        "username": username,
        "email": email,
      });

      // Logout user after sign-up to prevent auto-login
      await _auth.signOut();

      return "Verification email sent! Please verify before logging in.";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Login with Email & Password
  Future<String?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        await _auth.signOut(); // Prevent login without email verification
        return "Please verify your email before logging in.";
      }

      return null; // No errors
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Google Sign-In with Auto Username Generation
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return "Google Sign-In canceled.";

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      // Extract username from email (before @ symbol)
      String username = googleUser.email.split('@')[0];

      // Check if user already exists in Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user!.uid).get();
      if (!userDoc.exists) {
        await _firestore.collection("users").doc(user.uid).set({
          "fullName": googleUser.displayName ?? "User",
          "username": username,
          "email": googleUser.email,
        });
      }

      return null; // Success
    } catch (e) {
      return "Google Sign-In failed. Please try again.";
    }
  }

  // Forgot Password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Password reset link sent to your email!";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  // Get User Details from Firestore
  Future<Map<String, dynamic>?> getUserDetails() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot userDoc =
        await _firestore.collection("users").doc(user.uid).get();
    return userDoc.data() as Map<String, dynamic>?;
  }
}
