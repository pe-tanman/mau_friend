import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mau_friend/screens/settings/privacy_setting_screen.dart';
import 'package:mau_friend/screens/welcome/authGate.dart';
import 'package:mau_friend/screens/settings/current_location_screen.dart';
import 'package:mau_friend/screens/settings/profile_setting_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
              leading: Icon(Icons.policy_outlined),
              title: Text('Privacy Settings'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  PrivacySettingScreen.routeName,
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.article_outlined),
              title: Text('Privacy Policy'),
              trailing: Icon(Icons.open_in_new),
              onTap: () async{
                // Open the privacy policy URL
                final Uri privacyPolicyUrl = Uri.parse('https://petanman.notion.site/Privacy-Policy-1efe73611a8f804388a5d41b98b7165f?pvs=4');
                if (!await launchUrl(privacyPolicyUrl)) {
                  throw Exception('Could not launch $privacyPolicyUrl');
                }
              },
            ),
            
            ListTile(
              title: Text('Current Location'),
              leading: Icon(Icons.location_on_outlined),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  CurrentLocationScreen.routeName,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(
                  context,
                  AuthGate.routeName,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}