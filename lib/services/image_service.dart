import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery with validation
  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image == null) {
        return null;
      }

      // Validate file type
      final String extension = path.extension(image.path).toLowerCase();
      if (extension != '.jpg' && extension != '.jpeg' && extension != '.png') {
        throw Exception('Only JPG and PNG images are allowed');
      }

      // Validate file size (max 5MB)
      final file = File(image.path);
      final stat = await file.stat();
      if (stat.size > 5 * 1024 * 1024) {
        throw Exception('Image size must be less than 5MB');
      }

      return image;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Upload trail image to: trails/{trail_id}/main_photo.jpg
  Future<String> uploadTrailImage(XFile image, String trailId) async {
    try {
      final String storagePath = 'trails/$trailId/main_photo.jpg';
      final Reference storageReference = _storage.ref().child(storagePath);
      
      // Upload the file
      final UploadTask uploadTask = storageReference.putFile(File(image.path));
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        // Get the download URL
        return await storageReference.getDownloadURL();
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } catch (e) {
      throw Exception('Trail image upload failed: $e');
    }
  }

  // Upload user hike photo to: users/{user_id}/hike_photos/{log_entry_id}.jpg
  Future<String> uploadHikingLogImage(XFile image, String userId, String logEntryId) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String storagePath = 'users/$userId/hike_photos/$logEntryId/$fileName';
      
      final Reference storageReference = _storage.ref().child(storagePath);
      final UploadTask uploadTask = storageReference.putFile(File(image.path));
      
      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        return await storageReference.getDownloadURL();
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } catch (e) {
      throw Exception('Hiking log image upload failed: $e');
    }
  }

  // Delete image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
      // Don't throw error for delete failures
    }
  }

  // Get upload task for progress monitoring
  UploadTask getUploadTaskForHikingLog(XFile image, String userId, String logEntryId) {
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String storagePath = 'users/$userId/hike_photos/$logEntryId/$fileName';
    
    final Reference storageReference = _storage.ref().child(storagePath);
    return storageReference.putFile(File(image.path));
  }

  // Get upload task for trail image
  UploadTask getUploadTaskForTrailImage(XFile image, String trailId) {
    final String storagePath = 'trails/$trailId/main_photo.jpg';
    final Reference storageReference = _storage.ref().child(storagePath);
    return storageReference.putFile(File(image.path));
  }
}