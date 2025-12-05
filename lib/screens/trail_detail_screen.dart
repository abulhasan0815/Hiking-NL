import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hiking_app/models/trail.dart';
import 'package:hiking_app/services/trail_service.dart';
import 'package:hiking_app/config/app_theme.dart';

class TrailDetailScreen extends StatefulWidget {
  final String trailId;

  const TrailDetailScreen({super.key, required this.trailId});

  @override
  State<TrailDetailScreen> createState() => _TrailDetailScreenState();
}

class _TrailDetailScreenState extends State<TrailDetailScreen> {
  late Future<Trail?> _trailFuture;

  @override
  void initState() {
    super.initState();
    _trailFuture = Provider.of<TrailService>(
      context,
      listen: false,
    ).getTrailById(widget.trailId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trail Details'),
        elevation: 0,
      ),
      body: FutureBuilder<Trail?>(
        future: _trailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppTheme.hardRed),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading trail details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final trail = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // Hero Image
              SliverAppBar(
                expandedHeight: 250,
                floating: false,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: trail.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.lightGreen,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.lightGreen,
                            child: const Icon(Icons.photo, size: 64),
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppTheme.primaryGreen.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Difficulty Badge
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.getDifficultyColor(trail.difficulty),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.getDifficultyColor(trail.difficulty)
                                    .withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getDifficultyIcon(trail.difficulty),
                                color: AppTheme.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                trail.difficulty,
                                style: const TextStyle(
                                  color: AppTheme.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: AppTheme.primaryGreen,
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trail Title and Location
                      Text(
                        trail.name,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppTheme.primaryGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            trail.location,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppTheme.lightText,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Info Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              context,
                              Icons.straighten,
                              '${trail.length}',
                              'km',
                              AppTheme.skyBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDetailCard(
                              context,
                              Icons.schedule,
                              trail.estimatedTime,
                              'Duration',
                              AppTheme.sunsetOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Description Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGreen,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.accentGreen.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppTheme.primaryGreen,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'About This Trail',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppTheme.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              trail.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    height: 1.6,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Action Buttons
                      if (FirebaseAuth.instance.currentUser != null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push('/add-log/${trail.id}');
                            },
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Log This Hike'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: AppTheme.white,
                            ),
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push('/auth');
                            },
                            icon: const Icon(Icons.login),
                            label: const Text('Sign In to Log This Hike'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightText,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.trending_down;
      case 'moderate':
        return Icons.trending_flat;
      case 'hard':
        return Icons.trending_up;
      default:
        return Icons.info;
    }
  }
}
