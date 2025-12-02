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
    return const NetworkImage(
      'https://imgs.search.brave.com/QqdZUU85ynVfLUt2xRC6EjrJlrMP-ZEB2HXiC6rB7u4/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzL2U1L2Q3/L2I4L2U1ZDdiODI4/NDAwNjEwM2E1MGY0/NmE3MTZkMTBjY2Jh/LmpwZw',
    );
  }

  void _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _onDashboardTap() {
    // TODO: Navigate to dashboard page if it's different from HomePage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dashboard clicked')),
    );
  }

  void _onUserListTap() {
    // TODO: Navigate to user list page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User list (normal / paid) clicked')),
    );
  }

  void _onSettingsTap() {
    // TODO: Navigate to settings page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings clicked')),
    );
  }

  Widget _buildUserList() {
    return ListView.separated(
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
    );
  }

  Drawer _buildMobileDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFE6BFF0),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Welcome ${widget.userName}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                _onDashboardTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('User list'),
              onTap: () {
                Navigator.pop(context);
                _onUserListTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _onSettingsTap();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFE6BFF0),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0, 2),
            color: Colors.black12,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Left: Welcome text
          Text(
            'Welcome ${widget.userName}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(),

          // Center/right: menu items
          Row(
            children: [
              TextButton.icon(
                onPressed: _onDashboardTap,
                icon: const Icon(Icons.dashboard_outlined, size: 18),
                label: const Text('Dashboard'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _onUserListTap,
                icon: const Icon(Icons.people_outline, size: 18),
                label: const Text('User list'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _onSettingsTap,
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: const Text('Settings'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Right: logout icon
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      // Mobile: AppBar + hamburger
      appBar: isMobile
          ? AppBar(
              backgroundColor: const Color(0xFFE6BFF0),
              toolbarHeight: 80,
              title: Text(
                'Welcome ${widget.userName}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0,
            )
          : null,
      drawer: isMobile ? _buildMobileDrawer() : null,

      body: Column(
        children: [
          // Web: custom top header with menu
          if (!isMobile) _buildWebHeader(context),

          // The list of users -- expanded to fill remaining space
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }
}
