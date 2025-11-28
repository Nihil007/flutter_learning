import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/centered_card.dart';
import 'login_page.dart';

class ResetWithTokenPage extends StatefulWidget {
  final String resetToken;
  const ResetWithTokenPage({super.key, required this.resetToken});

  @override
  State<ResetWithTokenPage> createState() => _ResetWithTokenPageState();
}

class _ResetWithTokenPageState extends State<ResetWithTokenPage> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _reset() async {
    final p = _passCtrl.text.trim();
    final c = _confirmCtrl.text.trim();

    if (p.isEmpty || c.isEmpty) {
      setState(() => _error = "Fill all fields");
      return;
    }
    if (p.length < 6) {
      setState(() => _error = "Password must be at least 6 characters");
      return;
    }
    if (p != c) {
      setState(() => _error = "Passwords do not match");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    final resp = await ApiService.resetWithToken(widget.resetToken, p);

    setState(() => _loading = false);

    if (resp['success'] == true) {
      setState(() => _success = resp['message'] ?? "Password reset successful");
      Future.delayed(const Duration(milliseconds: 900), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      });
    } else {
      setState(() => _error = resp['message'] ?? "Reset failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxWidth = width > 900 ? 540.0 : 420.0;

    return Scaffold(
      appBar: AppBar(title: const Text("Set new password")),
      body: CenteredCard(
        maxWidth: maxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Create a new password",
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_reset),
              ),
            ),
            const SizedBox(height: 12),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            if (_success != null)
              Text(_success!, style: const TextStyle(color: Colors.green)),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _reset,
                      child: const Text("Set Password"),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
