// Simple splash screen used by the app.
// File: lib/onboarding/splash.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;

      final session = Hive.box('session');
      final user = session.get('currentUser');

      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_fire_department, size: 110, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Welcome',
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge!.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Let\'s get started',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
