import 'package:flutter/material.dart';
import 'package:mau_friend/screens/profile_setting_screen.dart';

class SettingScreen extends StatefulWidget {
  static const routeName = '/settings';
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String username = 'Username';
  String bio = 'Bio goes here...';
  String profileImage = 'assets/profile_placeholder.png'; // Replace with actual image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  ProfileSettingScreen.routeName,
            );
              },
            ),
            ListTile(
              leading: Icon(Icons.lock_outlined),
              title: Text('Security Settings'),
              onTap: () {
                // Navigate to security settings screen
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: () {
                // Handle log out
              },
            ),
          ],
        ),
      ),
    );
  }
}