import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/my_status_provider.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/providers/notification_provider.dart';
import 'package:mau_friend/screens/notification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mau_friend/screens/add_friend_screen.dart';
import 'package:mau_friend/screens/profile_setting_screen.dart';
import 'package:mau_friend/themes/app_color.dart';
import 'package:mau_friend/utilities/statics.dart';
import 'package:mau_friend/providers/friend_list_provider.dart';

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

    friendsSubscription = FirebaseFirestore.instance
        .collection('friendList')
        .doc(myUID)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            if (snapshot.data()!['friendList'].length >
                ref.read(friendListProvider).length) {
              ref.read(friendListProvider.notifier).loadFriendList().then((_) {
                //check if new friend added
                //get the new friend
                final newFriend = snapshot.data()!['friendList'].last;
                final newFriendProfile =
                    snapshot.data()!['profiles'][newFriend];
                final newFriendName = newFriendProfile['username'];
                final newFriendIconLink = newFriendProfile['iconLink'];
                ref
                    .read(notificationProvider.notifier)
                    .addNotification(
                      '$newFriendName is now your friend.',
                      newFriendIconLink,
                    );
              });
            } else if (snapshot.data()!['friendList'].length <
                ref.read(friendListProvider).length) {
              ref.read(friendListProvider.notifier).loadFriendList().then((_) {
                //check if new friend added
                //get the new friend
                final newFriend = snapshot.data()!['friendList'].last;
                final newFriendProfile =
                    snapshot.data()!['profiles'][newFriend];
                final newFriendName = newFriendProfile['username'];
                final newFriendIconLink = newFriendProfile['iconLink'];
                ref
                    .read(notificationProvider.notifier)
                    .addNotification(
                      'You blocked $newFriendName',
                      newFriendIconLink,
                    );
              });
            }
          }
        });
  }

  Widget buildFriendCard(String friendUID) {
    print('friendUID:$friendUID');
    final profile = ref.watch(friendProfilesProvider)[friendUID];
    return Card(
      color: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      elevation: 3.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              profile?.iconLink ?? Statics.defaultIconLink, // default icon link
            ),
          ), // a cat image
          SizedBox(height: 20),
          Text(
            profile?.name ?? 'Username',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            profile?.bio ?? 'Bio',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 60),

          //status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ref.watch(myStatusProvider).icon,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  ref.watch(myStatusProvider).status,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotificationButton() {
    if (ref.watch(unreadNotificationProvider) > 0) {
      return Badge.count(
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
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () {
          Navigator.pushNamed(context, NotificationScreen.routeName);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    friendList = ref.watch(friendListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildNotificationButton(),
          ),
        ],
      ),
      //horizontal scroll
      body:
          friendList.isEmpty
              ? Center(child: Text("Let's add friends by pressing + button"))
              : PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: PageController(viewportFraction: 0.8),
                itemCount: friendList.length,
                itemBuilder: (context, index) {
                  final friendUID = friendList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 80,
                    ),
                    child: buildFriendCard(friendUID),
                  );
                },
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
