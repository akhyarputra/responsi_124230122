import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final users = Hive.box('users');
    final session = Hive.box('session');

    final username = _usernameController.text.trim();

    // prevent duplicate usernames
    if (users.containsKey(username)) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Username sudah digunakan')));
      return;
    }

    // Save user (NOTE: passwords stored in plain text for demo)
    await users.put(username, {
      'username': username,
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
    });

    // Save session
    await session.put('currentUser', {'username': username});

    setState(() => _isLoading = false);

    if (!mounted) return;
    // Navigate to categories as requested
    Navigator.of(context).pushReplacementNamed('/categories');
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = Colors.black87;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Let\'s get you started!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 12),
              _buildTextField(
                label: 'Username',
                icon: Icons.badge_outlined,
                controller: _usernameController,
              ),
              const SizedBox(height: 12),

              const SizedBox(height: 12),
              _buildTextField(
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: _getTextFieldDecoration(
                  label: 'Password',
                  icon: Icons.lock_outline,
                ),
                validator: (value) => value == null || value.length < 8
                    ? 'Password minimal 8 karakter'
                    : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: _getTextFieldDecoration(
                  label: 'Re-type Password',
                  icon: Icons.lock_reset_outlined,
                ),
                validator: (value) => value != _passwordController.text
                    ? 'Password tidak cocok'
                    : null,
              ),
              const SizedBox(height: 20),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleSignup,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        child: Text('Sign Up'),
                      ),
                    ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: _getTextFieldDecoration(label: label, icon: icon),
      validator: (value) =>
          value == null || value.isEmpty ? '$label tidak boleh kosong' : null,
    );
  }

  InputDecoration _getTextFieldDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }
}
