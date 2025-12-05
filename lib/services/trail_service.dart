import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hiking_app/models/trail.dart';

class TrailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all trails without any filtering - we'll do filtering client-side
  Stream<List<Trail>> getTrails() {
    return _firestore
        .collection('trails')
        .orderBy('name') // Default sort by name
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>?;
              if (data != null) {
                return Trail.fromMap(data, doc.id);
              } else {
                // Return a default trail if data is null
                return Trail(
                  id: doc.id,
                  name: 'Unknown Trail',
                  location: 'Unknown Location',
                  difficulty: 'Easy',
                  length: 0.0,
                  estimatedTime: 'Unknown',
                  description: 'No description available',
                  imageUrl: '',
                );
              }
            })
            .toList());
  }

  Future<Trail?> getTrailById(String trailId) async {
    try {
      final doc = await _firestore.collection('trails').doc(trailId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return Trail.fromMap(data, doc.id);
        }
      }
      return null;
    } catch (e) {
      print('Error getting trail by ID: $e');
      return null;
    }
  }

  // Get unique locations for filter
  Future<List<String>> getTrailLocations() async {
    try {
      final snapshot = await _firestore.collection('trails').get();
      final locations = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['location'] as String?;
          })
          .where((location) => location != null)
          .cast<String>()
          .toSet()
          .toList();
      locations.sort();
      return locations;
    } catch (e) {
      print('Error getting trail locations: $e');
      return [];
    }
  }

  // Get unique difficulties for filter
  Future<List<String>> getTrailDifficulties() async {
    try {
      final snapshot = await _firestore.collection('trails').get();
      final difficulties = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['difficulty'] as String?;
          })
          .where((difficulty) => difficulty != null)
          .cast<String>()
          .toSet()
          .toList();
      difficulties.sort();
      return difficulties;
    } catch (e) {
      print('Error getting trail difficulties: $e');
      return [];
    }
  }
}