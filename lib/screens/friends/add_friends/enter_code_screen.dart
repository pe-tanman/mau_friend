import 'package:flutter/material.dart';
import 'package:mau_friend/screens/friends/add_friends/friend_profile_screen.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';

class EnterCodeScreen extends StatefulWidget {
  static const routeName = '/enter-code';
  @override
  _EnterCodeScreenState createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final TextEditingController _codeController = TextEditingController();

  Future<void> _submitCode() async {
    final code = _codeController.text.trim();
    String userUID = code.split('+')[0];
    String password = code.split('+')[1];

    if (userUID.isNotEmpty && password.isNotEmpty) {
  
        final storedAddress = await FirestoreHelper().getPermanentAddress(userUID);
        if (storedAddress == code) {
          // Navigate to the friend's profile screen
          Navigator.of(context).pushNamed(
            FriendProfileScreen.routeName,
            arguments: [userUID, true],
          );
          return;
        }
    }
      // Show error or feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid permanent code')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Text(
              'Send friend request by entering permanent code',
            ),
            SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Code',
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitCode,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}