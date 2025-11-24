// Simplified, self-contained login screen used by this project.
// File: lib/auth/login.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // Simulate a small delay
    await Future.delayed(const Duration(milliseconds: 600));

    final users = Hive.box('users');
    final session = Hive.box('session');

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final stored = users.get(username);
    if (stored != null && stored is Map && stored['password'] == password) {
      // Save session
      await session.put('currentUser', {'username': username});

      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/categories');
      return;
    }

    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid username or password')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 92,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text('Welcome Back', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Please sign in to continue',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter username' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter password' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _submit,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14.0),
                              child: Text('Sign In'),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/signup');
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
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
      ),
    );
  }
}
