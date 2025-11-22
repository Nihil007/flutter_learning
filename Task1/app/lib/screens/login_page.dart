import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'register_page.dart';
import 'home_page.dart';
import '../widgets/centered_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Please enter email and password';
      });
      return;
    }

    final resp = await ApiService.login(email, pass);
    setState(() {
      _loading = false;
    });

    if (resp['success']) {
      final user = resp['data']['user'];
      final userName = user['name'] ?? '';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(userName: userName)),
      );
    } else {
      setState(() {
        _error = resp['message'] ?? 'Login failed';
      });
    }
  }

  void _forgotPassword() {
    // Dummy for now
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Forgot password pressed — dummy for now.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use narrower max width for mobile-like screens,
    // allow slightly wider on web by checking kIsWeb or screen width.
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = kIsWeb ? (screenWidth > 900 ? 540.0 : 420.0) : 420.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: CenteredCard(
        maxWidth: maxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text('Welcome back', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: _loading
                  ? const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(),
                    ))
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Login'),
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                  child: const Text('Sign up'),
                ),
                TextButton(
                  onPressed: _forgotPassword,
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
            // const SizedBox(height: 6),
            // // Helpful small hint
            // Text('Running on: ${kIsWeb ? "Web (localhost)" : "Android emulator (10.0.2.2)"}',
            //     style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
