import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:hiking_app/models/hiking_log.dart';
import 'package:hiking_app/config/app_theme.dart';

class HikingLogCard extends StatelessWidget {
  final HikingLog log;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HikingLogCard({
    super.key,
    required this.log,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Log Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: log.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 100,
                      height: 100,
                      color: AppTheme.lightGreen,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 100,
                      color: AppTheme.lightGreen,
                      child: const Icon(Icons.photo, color: AppTheme.lightText),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Log Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trail Name
                      Text(
                        log.trailName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppTheme.lightText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(log.dateCompletedAsDateTime),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.lightText,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Rating Stars
                      _buildRatingStars(log.rating),
                      const SizedBox(height: 8),
                      // Notes Preview
                      if (log.notes.isNotEmpty)
                        Text(
                          log.notes,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.lightText,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Action Button
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Tooltip(
                      message: 'Delete log',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onDelete,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.hardRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: AppTheme.hardRed,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            index < rating ? Icons.star : Icons.star_outline,
            color: index < rating ? AppTheme.sunsetOrange : AppTheme.borderGrey,
            size: 18,
          ),
        );
      }),
    );
  }
}