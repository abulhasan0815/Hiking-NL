import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/trail_discovery_screen.dart';
import 'screens/trail_detail_screen.dart';
import 'screens/hiking_logs_screen.dart';
import 'screens/add_edit_log_screen.dart';

class AppRouter {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'trails',
            builder: (context, state) => const TrailDiscoveryScreen(),
          ),
          GoRoute(
            path: 'trail/:id',
            builder: (context, state) {
              final trailId = state.pathParameters['id']!;
              return TrailDetailScreen(trailId: trailId);
            },
          ),
          GoRoute(
            path: 'logs',
            builder: (context, state) => const HikingLogsScreen(),
          ),
          GoRoute(
            path: 'add-log/:trailId',
            builder: (context, state) {
              final trailId = state.pathParameters['trailId']!;
              return AddEditLogScreen(trailId: trailId);
            },
          ),
          GoRoute(
            path: 'edit-log/:logId',
            builder: (context, state) {
              final logId = state.pathParameters['logId']!;
              return AddEditLogScreen(logId: logId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
    ],
    redirect: (context, state) {
      final user = _auth.currentUser;
      final goingToAuth = state.uri.path == '/auth';

      // If user is not signed in and not going to auth page, redirect to auth
      if (user == null && !goingToAuth) {
        return '/auth';
      }
      // If user is signed in and going to auth page, redirect to home
      else if (user != null && goingToAuth) {
        return '/';
      }
      // No redirect needed
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}