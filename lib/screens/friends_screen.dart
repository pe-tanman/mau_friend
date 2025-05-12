import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/providers/notification_provider.dart';
import 'package:mau_friend/screens/notification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mau_friend/screens/add_friend_screen.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  List friendList = [];
  List profileList = [Profile];
  String userState = 'offline';
  late StreamSubscription friendsSubscription;

  @override
  void initState() {
    super.initState();
    final myUID = FirebaseAuth.instance.currentUser?.uid;

    ref.read(friendProfilesProvider.notifier).loadFriendProfiles();
    //no notification 

    friendsSubscription = FirebaseFirestore.instance
        .collection('friendList')
        .doc(myUID)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            print('Friend list updated');
            ref.read(friendProfilesProvider.notifier).loadFriendProfiles();
            friendList = snapshot.data()!['friendsList'];
            final newFriend = snapshot.data()!['friendsList'].last;

            final newFriendProfile = snapshot.data()!['profiles'][newFriend];
            final newFriendName = newFriendProfile['name'];
            final newFriendIconLink = newFriendProfile['iconLink'];
            ref.read(notificationProvider.notifier).addNotification('$newFriendName is now your friend.', newFriendIconLink);
          }
        });


  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          if (ref.watch(unreadNotificationProvider) > 0)
            Badge.count(
              count: ref.watch(unreadNotificationProvider),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, NotificationScreen.routeName);
                  ref
                      .watch(unreadNotificationProvider.notifier)
                      .resetUnreadNotification();
                },
              ),
            ),
          if (ref.watch(unreadNotificationProvider) == 0)
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.pushNamed(context, NotificationScreen.routeName);
              },
            ),
        ],
      ),
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
