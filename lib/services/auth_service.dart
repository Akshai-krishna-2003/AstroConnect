import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

      // Logout user after sign-up to prevent auto-login before verification
      await _auth.signOut();

      return "Verification email sent! Please check your inbox and also check Spam or Promotions folders. Verify before logging in.";
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

      // Check verification status without reload first
      if (userCredential.user!.emailVerified) {
        return null; // Already verified
      }

      // If not verified, reload and check again
      await userCredential.user!.reload();
      User? refreshedUser = _auth.currentUser;

      if (refreshedUser == null || !refreshedUser.emailVerified) {
        await _auth.signOut();
        return "Please verify your email before logging in.";
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Forgot Password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Password reset link sent to your email ... Check email or spam folder!";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
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
