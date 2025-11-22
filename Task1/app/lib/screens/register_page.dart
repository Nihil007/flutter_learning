import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/centered_card.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Please fill all fields';
      });
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        _loading = false;
        _error = 'Enter a valid email';
      });
      return;
    }

    final resp = await ApiService.register(name, email, pass);
    setState(() {
      _loading = false;
    });

    if (resp['success']) {
      setState(() {
        _success = 'Account created. Redirecting to login...';
      });
      Future.delayed(const Duration(milliseconds: 900), () {
        Navigator.pop(context);
      });
    } else {
      setState(() {
        _error = resp['message'] ?? 'Register failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 900 ? 540.0 : 420.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: CenteredCard(
        maxWidth: maxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create an account', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 12),
            TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))),
            const SizedBox(height: 12),
            TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
            const SizedBox(height: 12),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            if (_success != null) ...[
              Text(_success!, style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: _loading
                  ? const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Center(child: CircularProgressIndicator()))
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Create account'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
