import 'package:cloud_firestore/cloud_firestore.dart';

class SampleDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSampleTrails() async {
    try {
      final trails = [
        {
          'name': 'Signal Hill Trail',
          'location': 'St. John\'s',
          'difficulty': 'Hard',
          'length': 2.5,
          'estimatedTime': '45 min',
          'description': 'Historic site with harbor views and stunning coastal scenery. Offers panoramic views of St. John\'s harbor and the Atlantic Ocean.',
          'imageUrl': 'https://images.unsplash.com/photo-1571868231072-9a8150b75f8e?w=400&h=300&fit=crop',
        },
        {
          'name': 'Cape Spear Path',
          'location': 'Cape Spear',
          'difficulty': 'Moderate',
          'length': 3.2,
          'estimatedTime': '1 hour',
          'description': 'Easternmost point in North America with breathtaking coastal views and historic lighthouse.',
          'imageUrl': 'https://images.unsplash.com/photo-1501555088652-021faa106b9b?w=400&h=300&fit=crop',
        },
        {
          'name': 'Pippy Park Trails',
          'location': 'St. John\'s',
          'difficulty': 'Easy',
          'length': 4.0,
          'estimatedTime': '1.5 hours',
          'description': 'Urban park with multiple trail options through forests and along waterways in the heart of St. John\'s.',
          'imageUrl': 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=400&h=300&fit=crop',
        },
        {
          'name': 'Heart\'s Content Trail',
          'location': 'Trinity Bay',
          'difficulty': 'Moderate',
          'length': 5.5,
          'estimatedTime': '2 hours',
          'description': 'Coastal trail through historic cable station area with beautiful ocean views and forest paths.',
          'imageUrl': 'https://images.unsplash.com/photo-1464822759844-d94c9c57e45b?w=400&h=300&fit=crop',
        },
        {
          'name': 'Bowring Park Loop',
          'location': 'St. John\'s',
          'difficulty': 'Easy',
          'length': 2.0,
          'estimatedTime': '30 min',
          'description': 'Scenic city park with duck pond, beautiful gardens, and gentle walking paths perfect for families.',
          'imageUrl': 'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?w=400&h=300&fit=crop',
        },
        {
          'name': 'East Coast Trail - Cobbler Path',
          'location': 'Bay Bulls',
          'difficulty': 'Hard',
          'length': 8.5,
          'estimatedTime': '4 hours',
          'description': 'Spectacular coastal hiking with sea stacks, seabird colonies, and dramatic cliff views.',
          'imageUrl': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
        },
        {
          'name': 'La Manche Village Path',
          'location': 'Southern Shore',
          'difficulty': 'Moderate',
          'length': 6.0,
          'estimatedTime': '2.5 hours',
          'description': 'Trail leading to abandoned fishing village with suspension bridge and beautiful coastal scenery.',
          'imageUrl': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400&h=300&fit=crop',
        }
      ];

      // Use batch write for better performance
      final batch = _firestore.batch();
      
      for (var trail in trails) {
        final docRef = _firestore.collection('trails').doc();
        batch.set(docRef, trail);
      }
      
      await batch.commit();
      print('Successfully added ${trails.length} sample trails');
    } catch (e) {
      print('Error adding sample trails: $e');
      rethrow;
    }
  }

  Future<bool> checkIfTrailsExist() async {
    try {
      final snapshot = await _firestore.collection('trails').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if trails exist: $e');
      return false;
    }
  }
}