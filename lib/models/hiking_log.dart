import 'package:cloud_firestore/cloud_firestore.dart';

class HikingLog {
  final String id;
  final String trailId;
  final String trailName;
  final Timestamp dateCompleted; // Changed from DateTime to Timestamp
  final String notes;
  final int rating;
  final String imageUrl;
  final String userId;
  final Timestamp createdAt;

  HikingLog({
    required this.id,
    required this.trailId,
    required this.trailName,
    required this.dateCompleted,
    required this.notes,
    required this.rating,
    required this.imageUrl,
    required this.userId,
    required this.createdAt,
  });

  factory HikingLog.fromMap(Map<String, dynamic> data, String id) {
    return HikingLog(
      id: id,
      trailId: data['trailId'] ?? '',
      trailName: data['trailName'] ?? '',
      dateCompleted: data['dateCompleted'] ?? Timestamp.now(),
      notes: data['notes'] ?? '',
      rating: data['rating'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trailId': trailId,
      'trailName': trailName,
      'dateCompleted': dateCompleted,
      'notes': notes,
      'rating': rating,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Helper method to get DateTime from Timestamp for UI display
  DateTime get dateCompletedAsDateTime => dateCompleted.toDate();
  DateTime get createdAtAsDateTime => createdAt.toDate();
}