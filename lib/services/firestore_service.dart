import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserData(String userId, String name, String email) async {
    await _firestore.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot> getUserData(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }
}
