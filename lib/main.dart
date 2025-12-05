import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:hiking_app/app_router.dart';
import 'package:hiking_app/services/auth_service.dart';
import 'package:hiking_app/services/trail_service.dart';
import 'package:hiking_app/services/hiking_log_service.dart';
import 'package:hiking_app/services/image_service.dart';
import 'package:hiking_app/services/sample_data_service.dart';
import 'package:hiking_app/config/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configure FirebaseUI
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
  ]);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<TrailService>(create: (_) => TrailService()),
        Provider<HikingLogService>(create: (_) => HikingLogService()),
        Provider<ImageService>(create: (_) => ImageService()),
        Provider<SampleDataService>(create: (_) => SampleDataService()),
      ],
      child: MaterialApp.router(
        title: 'NL Hikes',
        theme: AppTheme.lightTheme,
        routerConfig: _appRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}