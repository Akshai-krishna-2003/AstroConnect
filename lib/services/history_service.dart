import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveHoroscopeHistory(String userId, String horoscope) async {
    await _firestore.collection('users').doc(userId).collection('history').add({
      'horoscope': horoscope,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getHoroscopeHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
