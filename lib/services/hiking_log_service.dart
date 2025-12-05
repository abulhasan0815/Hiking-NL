import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hiking_app/models/hiking_log.dart';

class HikingLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  Stream<List<HikingLog>> getHikingLogs() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('my_completed_hikes')
        .orderBy('dateCompleted', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>?;
              if (data != null) {
                return HikingLog.fromMap(data, doc.id);
              } else {
                // Return a default log if data is null
                return HikingLog(
                  id: doc.id,
                  trailId: '',
                  trailName: 'Unknown Trail',
                  dateCompleted: Timestamp.now(),
                  notes: '',
                  rating: 0,
                  imageUrl: '',
                  userId: _userId,
                  createdAt: Timestamp.now(),
                );
              }
            })
            .toList());
  }

  Future<void> addHikingLog(HikingLog log) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('my_completed_hikes')
        .add(log.toMap());
  }

  Future<void> updateHikingLog(HikingLog log) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('my_completed_hikes')
        .doc(log.id)
        .update(log.toMap());
  }

  Future<void> deleteHikingLog(String logId) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('my_completed_hikes')
        .doc(logId)
        .delete();
  }

  Future<HikingLog?> getHikingLogById(String logId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('my_completed_hikes')
          .doc(logId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return HikingLog.fromMap(data, doc.id);
        }
      }
      return null;
    } catch (e) {
      print('Error getting hiking log by ID: $e');
      return null;
    }
  }
}