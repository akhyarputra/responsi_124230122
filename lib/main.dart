import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'onboarding/splash.dart';
import 'auth/login.dart';
import 'auth/signup.dart';
import 'features/categories.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Open boxes
  await Hive.openBox('users');
  await Hive.openBox('session');
  // Boxes for caching API responses
  await Hive.openBox('cache_categories');
  await Hive.openBox('cache_meals');
  await Hive.openBox('cache_meal_detail');

  // Ensure there's a default test user if no users exist
  final users = Hive.box('users');
  if (users.isEmpty) {
    // store a simple username/password map; in a real app passwords should be hashed
    users.put('testuser', {'username': 'testuser', 'password': 'password123'});
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFFFF6A3D); // orange-red
    final accent = const Color(0xFFEF3B2D);

    final colorScheme = ColorScheme.fromSeed(seedColor: primary).copyWith(
      primary: primary,
      secondary: accent,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Responsi App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/home': (context) => const _HomePage(),
      },
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home screen - logged in')),
    );
  }
}
