import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hiking_app/models/hiking_log.dart';
import 'package:hiking_app/services/hiking_log_service.dart';
import 'package:hiking_app/widgets/hiking_log_card.dart';
import 'package:hiking_app/config/app_theme.dart';

class HikingLogsScreen extends StatelessWidget {
  const HikingLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Hiking Logs')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 80, color: AppTheme.lightText),
              const SizedBox(height: 24),
              Text(
                'Sign In to View Logs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Track your hiking adventures',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
                onPressed: () => context.push('/auth'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Hiking Logs'),
        elevation: 0,
        actions: [
          Tooltip(
            message: 'Log a new hike',
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                context.push('/trails');
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<HikingLog>>(
        stream: Provider.of<HikingLogService>(context).getHikingLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppTheme.hardRed),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading hiking logs',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: () {},
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hiking, size: 80, color: AppTheme.lightText),
                  const SizedBox(height: 24),
                  Text(
                    'No hiking logs yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your journey by discovering trails\nand logging your first hike!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/trails');
                    },
                    icon: const Icon(Icons.explore),
                    label: const Text('Discover Trails'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final logs = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // Stats Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Progress',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              '${logs.length}',
                              'Hikes',
                              Icons.check_circle,
                              AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              '${logs.fold<double>(0, (sum, log) => sum + (log.rating * 0.5)).toStringAsFixed(1)}',
                              'Total Rating',
                              Icons.star,
                              AppTheme.sunsetOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Logs List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final log = logs[index];
                    return HikingLogCard(
                      log: log,
                      onTap: () {
                        context.push('/edit-log/${log.id}');
                      },
                      onDelete: () {
                        _showDeleteDialog(context, log);
                      },
                    );
                  },
                  childCount: logs.length,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, HikingLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_outlined, color: AppTheme.sunsetOrange, size: 28),
            const SizedBox(width: 8),
            const Text('Delete Log'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete your log for "${log.trailName}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<HikingLogService>(context, listen: false)
                  .deleteHikingLog(log.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Log deleted successfully'),
                  backgroundColor: AppTheme.hardRed,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.hardRed, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}