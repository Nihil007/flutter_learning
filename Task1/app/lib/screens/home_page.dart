import 'package:flutter/material.dart';
import 'login_page.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _name = '';

  @override
  void initState() {
    super.initState();
    _name = widget.userName;
  }

  void _logout() async {
    await ApiService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Small centered layout for Home page so title is centered on wide screens too
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello $_name'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Hello $_name', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                const SizedBox(height: 18),
                const Text('Welcome to the app — everything is centered and responsive now.', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
