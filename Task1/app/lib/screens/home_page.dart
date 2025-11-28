// lib/screens/home_page.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Example users list (you can replace with real data)
  final List<Map<String, String>> _users = [
    {'name': 'Shadha'},
    {'name': 'Bala'},
    {'name': 'Pikachu'},
  ];

  // Local uploaded image path (the file you provided)
  // The system saved this file for you at this path:
  final String _localAvatarPath = '/mnt/data/Your paragraph text.png';

  // If running on the web, FileImage won't work; use a fallback network/asset image:
  ImageProvider _avatarProvider() {
    if (!kIsWeb && File(_localAvatarPath).existsSync()) {
      return FileImage(File(_localAvatarPath));
    }
    // fallback - a simple network avatar; change to your asset if you prefer
    return const NetworkImage('https://imgs.search.brave.com/QqdZUU85ynVfLUt2xRC6EjrJlrMP-ZEB2HXiC6rB7u4/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzL2U1L2Q3/L2I4L2U1ZDdiODI4/NDAwNjEwM2E1MGY0/NmE3MTZkMTBjY2Jh/LmpwZw');
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
    // large header height and large font sizes to match the screenshot
    return Scaffold(
      body: Column(
        children: [
          // Top header
          Container(
            width: double.infinity,
            color: const Color(0xFFE6BFF0), // soft purple like screenshot
            padding: const EdgeInsets.only(left: 18, top: 42, bottom: 12),
            // top padding accounts for status bar; adjust if needed
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Welcome ${widget.userName}',
                style: const TextStyle(
                  fontSize: 30, // large font like screenshot
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          // The list of users -- expanded to fill remaining space
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              itemCount: _users.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = _users[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // avatar
                    CircleAvatar(
                      radius: 25, // circle 
                      backgroundImage: _avatarProvider(),
                      backgroundColor: Colors.grey[100],
                    ),
                    const SizedBox(width: 18),
                    // user name text
                    Text(
                      user['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      // optional floating logout button or AppBar action
      floatingActionButton: FloatingActionButton(
        onPressed: _logout,
        child: const Icon(Icons.logout),
        tooltip: 'Logout',
      ),
    );
  }
}
