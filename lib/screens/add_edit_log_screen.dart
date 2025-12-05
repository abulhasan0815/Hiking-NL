import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hiking_app/models/hiking_log.dart';
import 'package:hiking_app/models/trail.dart';
import 'package:hiking_app/services/trail_service.dart';
import 'package:hiking_app/services/hiking_log_service.dart';
import 'package:hiking_app/services/image_service.dart';
import 'package:hiking_app/widgets/image_upload_widget.dart';
import 'package:hiking_app/config/app_theme.dart';

class AddEditLogScreen extends StatefulWidget {
  final String? trailId;
  final String? logId;

  const AddEditLogScreen({super.key, this.trailId, this.logId});

  @override
  State<AddEditLogScreen> createState() => _AddEditLogScreenState();
}

class _AddEditLogScreenState extends State<AddEditLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  Trail? _trail;
  DateTime _selectedDate = DateTime.now();
  int _rating = 5;
  String _imageUrl = '';
  bool _isLoading = false;
  bool _isEditMode = false;
  String? _logEntryId;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.logId != null;
    _logEntryId = widget.logId ?? DateTime.now().millisecondsSinceEpoch.toString();
    if (_isEditMode) {
      _loadExistingLog();
    } else {
      _loadTrail();
    }
  }

  Future<void> _loadTrail() async {
    if (widget.trailId != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final trail = await Provider.of<TrailService>(context, listen: false)
            .getTrailById(widget.trailId!);
        setState(() {
          _trail = trail;
        });
      } catch (e) {
        _showErrorDialog('Failed to load trail: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadExistingLog() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final log = await Provider.of<HikingLogService>(context, listen: false)
          .getHikingLogById(widget.logId!);
      if (log != null) {
        setState(() {
          _selectedDate = log.dateCompletedAsDateTime;
          _rating = log.rating;
          _imageUrl = log.imageUrl;
          _notesController.text = log.notes;
          _trail = Trail(
            id: log.trailId,
            name: log.trailName,
            location: '',
            difficulty: '',
            length: 0,
            estimatedTime: '',
            description: '',
            imageUrl: '',
          );
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to load log: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleImageUploaded(String imageUrl) {
    setState(() {
      _imageUrl = imageUrl;
    });
  }

  void _handleImageRemoved(String imageUrl) {
    setState(() {
      _imageUrl = '';
    });
    // Optionally delete from storage
    if (imageUrl.isNotEmpty) {
      Provider.of<ImageService>(context, listen: false).deleteImage(imageUrl);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _trail != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final log = HikingLog(
          id: widget.logId ?? '',
          trailId: _trail!.id,
          trailName: _trail!.name,
          dateCompleted: Timestamp.fromDate(_selectedDate),
          notes: _notesController.text,
          rating: _rating,
          imageUrl: _imageUrl,
          userId: FirebaseAuth.instance.currentUser!.uid,
          createdAt: Timestamp.now(),
        );

        if (_isEditMode) {
          await Provider.of<HikingLogService>(context, listen: false)
              .updateHikingLog(log);
        } else {
          await Provider.of<HikingLogService>(context, listen: false)
              .addHikingLog(log);
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Log updated successfully!' : 'Log created successfully!',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        context.pop();
      } catch (e) {
        _showErrorDialog('Failed to save log: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.hardRed, size: 28),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
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
    final user = FirebaseAuth.instance.currentUser;

    if (_isLoading && !_isEditMode) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Hiking Log' : 'Log a Hike'),
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryGreen,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Hiking Log' : 'Log a Hike'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_trail != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.landscape, color: AppTheme.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _trail!.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _trail!.location,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.white.withOpacity(0.9),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // Date Picker
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderGrey),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppTheme.primaryGreen, size: 24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date Completed',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.lightText,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.edit, color: AppTheme.accentGreen),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Rating Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: AppTheme.primaryGreen, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Rate Your Experience',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rating = index + 1;
                                });
                              },
                              child: Icon(
                                index < _rating ? Icons.star : Icons.star_outline,
                                color: index < _rating
                                    ? AppTheme.sunsetOrange
                                    : AppTheme.lightText,
                                size: 40,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '$_rating/5 - ${_getRatingLabel(_rating)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Notes
              Text(
                'Your Experience (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts about this hike...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryGreen,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppTheme.white,
                ),
                maxLines: 4,
                maxLength: 200,
                validator: (value) {
                  if (value != null && value.length > 200) {
                    return 'Notes must be less than 200 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Image Upload
              Text(
                'Hike Photo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              if (user != null)
                ImageUploadWidget(
                  currentImageUrl: _imageUrl,
                  onImageUploaded: _handleImageUploaded,
                  onImageRemoved: _handleImageRemoved,
                  uploadPath: 'hiking_log',
                  entityId: _logEntryId!,
                  userId: user.uid,
                ),
              const SizedBox(height: 32),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: Icon(_isEditMode ? Icons.check : Icons.save),
                  label: Text(
                    _isEditMode ? 'Update Log' : 'Save Log',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Not Great';
      case 2:
        return 'Could Be Better';
      case 3:
        return 'Good';
      case 4:
        return 'Excellent';
      case 5:
        return 'Amazing!';
      default:
        return '';
    }
  }
}