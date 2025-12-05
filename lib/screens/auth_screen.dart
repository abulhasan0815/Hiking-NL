import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [EmailAuthProvider()],
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          // Navigate to home screen after successful sign in
          context.go('/');
        }),
        AuthStateChangeAction<UserCreated>((context, state) {
          // Navigate to home screen after successful user creation
          context.go('/');
        }),
        ForgotPasswordAction((context, email) {
          // Handle forgot password - you can implement this later
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ForgotPasswordScreen(
                email: email,
                headerBuilder: (context, constraints, shrinkOffset) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset('assets/firebase_logo.png'),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}