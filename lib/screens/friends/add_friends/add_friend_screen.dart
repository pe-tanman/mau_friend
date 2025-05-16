import 'package:flutter/material.dart';
import 'package:mau_friend/screens/friends/add_friends/capture_qr_screen.dart';
import 'package:mau_friend/screens/friends/add_friends/my_qr_screen.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class AddFriendScreen extends StatelessWidget {
  static const routeName = 'add-friend-screen';
  const AddFriendScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Friend')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(tabs: [Tab(text: 'Scan QR'), Tab(text: 'My QR')]),
            Expanded(
              child: TabBarView(
                children: [
                  CaptureQrScreen(),
                  MyQrScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


