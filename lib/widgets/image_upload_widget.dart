import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadWidget extends StatefulWidget {
  final String? currentImageUrl;
  final Function(String) onImageUploaded;
  final Function(String) onImageRemoved;
  final String uploadPath; // Either 'trail' or 'hiking_log'
  final String entityId; // trailId or logEntryId
  final String userId; // Only needed for hiking_log

  const ImageUploadWidget({
    super.key,
    this.currentImageUrl,
    required this.onImageUploaded,
    required this.onImageRemoved,
    required this.uploadPath,
    required this.entityId,
    this.userId = '',
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  String? _imageUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.currentImageUrl;
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadImage(image);
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _uploadImage(XFile image) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      String downloadUrl;

      if (widget.uploadPath == 'trail') {
        // Upload trail image
        downloadUrl = await _uploadTrailImage(image);
      } else {
        // Upload hiking log image
        downloadUrl = await _uploadHikingLogImage(image);
      }

      setState(() {
        _imageUrl = downloadUrl;
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      widget.onImageUploaded(downloadUrl);
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      _showErrorDialog('Upload failed: $e');
    }
  }

  Future<String> _uploadTrailImage(XFile image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('trails/${widget.entityId}/main_photo.jpg');
    
    final uploadTask = storageRef.putFile(File(image.path));
    
    // Listen to progress
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      setState(() {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
      });
    });

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> _uploadHikingLogImage(XFile image) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('users/${widget.userId}/hike_photos/${widget.entityId}/$fileName');
    
    final uploadTask = storageRef.putFile(File(image.path));
    
    // Listen to progress
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      setState(() {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
      });
    });

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  void _removeImage() {
    setState(() {
      _imageUrl = null;
    });
    widget.onImageRemoved(_imageUrl ?? '');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _imageUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.photo, size: 64),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.white),
                      onPressed: _removeImage,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (_isUploading) ...[
          Column(
            children: [
              CircularProgressIndicator(value: _uploadProgress),
              const SizedBox(height: 8),
              Text('Uploading: ${(_uploadProgress * 100).toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 16),
        ],

        ElevatedButton.icon(
          onPressed: _isUploading ? null : _pickAndUploadImage,
          icon: const Icon(Icons.photo_library),
          label: const Text('Choose Photo'),
        ),

        const SizedBox(height: 8),
        Text(
          'Supported formats: JPG, PNG (Max 5MB)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}