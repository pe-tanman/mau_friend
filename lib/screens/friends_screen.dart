import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/screens/add_friend_screen.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  List locationList = [];
  String userState = 'offline';

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 100),
              const CircleAvatar(radius: 50),
              const SizedBox(height: 50),
              Text(userState),
              const SizedBox(height: 50),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Add location'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, AddFriendScreen.routeName);
        },
      ),
    );
  }
}
