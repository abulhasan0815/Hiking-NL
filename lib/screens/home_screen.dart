import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:provider/provider.dart';
import 'package:hiking_app/config/app_theme.dart';
import 'package:hiking_app/services/hiking_log_service.dart';
import 'package:hiking_app/models/hiking_log.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<List<HikingLog>> _hikesStream;
  
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _hikesStream = Provider.of<HikingLogService>(context, listen: false)
          .getHikingLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Section with Gradient
          SliverAppBar(
            expandedHeight: size.height * 0.35,
            floating: true,
            pinned: false,
            elevation: 0,
            backgroundColor: AppTheme.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.getHeroGradient(),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    // Content
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.terrain,
                            size: 64,
                            color: AppTheme.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'NL Hikes',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  color: AppTheme.white,
                                  fontSize: 40,
                                  letterSpacing: 2,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Discover Your Next Adventure',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppTheme.white.withOpacity(0.9),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (user != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Tooltip(
                      message: 'Profile',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<ProfileScreen>(
                                builder: (context) => ProfileScreen(
                                  appBar: AppBar(
                                    title: const Text('User Profile'),
                                    backgroundColor: AppTheme.primaryGreen,
                                  ),
                                  actions: [
                                    SignedOutAction((context) {
                                      context.go('/auth');
                                    }),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: AppTheme.accentGreen,
                            radius: 20,
                            child: Text(
                              user.email?.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                color: AppTheme.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  if (user != null) ...[
                    Text(
                      'Welcome back! 👋',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email ?? 'Hiker',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    Text(
                      'Start Your Journey',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to log your hiking adventures and track your progress',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Action Cards
                  _buildActionCard(
                    context,
                    icon: Icons.explore,
                    title: 'Discover Trails',
                    subtitle: 'Find amazing trails across Newfoundland',
                    color: AppTheme.primaryGreen,
                    onTap: () => context.push('/trails'),
                  ),
                  const SizedBox(height: 16),
                  if (user != null)
                    _buildActionCard(
                      context,
                      icon: Icons.library_books,
                      title: 'My Hiking Logs',
                      subtitle: 'Track your hiking journey',
                      color: AppTheme.sunsetOrange,
                      onTap: () => context.push('/logs'),
                    )
                  else
                    _buildActionCard(
                      context,
                      icon: Icons.login,
                      title: 'Sign In to Log Hikes',
                      subtitle: 'Create an account and start logging',
                      color: AppTheme.accentGreen,
                      onTap: () => context.push('/auth'),
                    ),
                  const SizedBox(height: 32),
                  // Stats Section (for logged-in users) - Real-time updates
                  if (user != null) ...[
                    Text(
                      'Your Statistics',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<HikingLog>>(
                      stream: _hikesStream,
                      builder: (context, snapshot) {
                        int hikeCount = 0;
                        
                        if (snapshot.hasData && snapshot.data != null) {
                          hikeCount = snapshot.data!.length;
                        }
                        
                        return Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(context, hikeCount.toString(), 'Hikes', AppTheme.primaryGreen),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(context, (hikeCount * 5).toString(), 'km', AppTheme.skyBlue),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Tips Section
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
                              Icons.lightbulb,
                              color: AppTheme.primaryGreen,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Hiking Tips',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: AppTheme.primaryGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Always bring plenty of water\n• Check weather before heading out\n• Wear appropriate footwear\n• Tell someone about your plans',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.white.withOpacity(0.9),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: AppTheme.white.withOpacity(0.8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
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
}