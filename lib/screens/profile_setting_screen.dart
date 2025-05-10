import 'package:flutter/material.dart';

class ProfileSettingScreen extends StatefulWidget {
  static const routeName = '/profile-setting';
  @override
  _ProfileSettingScreenState createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _selectedIcon;

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfileSettings() {
    // Save profile settings logic here
    print('Username: ${_usernameController.text}');
    print('Bio: ${_bioController.text}');
    print('Icon: $_selectedIcon');
  }

  void _selectIcon() async {
    // Logic to select an icon (e.g., from a list or gallery)
    // For simplicity, we'll just set a placeholder value
    setState(() {
      _selectedIcon = 'Selected Icon Placeholder';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings'),
        actions: [
          ElevatedButton(onPressed: _saveProfileSettings, child: Text('Save'))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Icon:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _selectIcon,
                  child: Text('Choose Icon'),
                ),
                if (_selectedIcon != null) ...[
                  SizedBox(width: 10),
                  Text(
                    _selectedIcon!,
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}