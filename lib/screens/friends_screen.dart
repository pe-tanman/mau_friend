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
            print('Friend list updated');
            ref.read(friendProfilesProvider.notifier).loadFriendProfiles();
            friendList = snapshot.data()!['friendsList'];
            final newFriend = snapshot.data()!['friendsList'].last;

            final newFriendProfile = snapshot.data()!['profiles'][newFriend];
            final newFriendName = newFriendProfile['name'];
            final newFriendIconLink = newFriendProfile['iconLink'];
            ref
                .read(notificationProvider.notifier)
                .addNotification(
                  '$newFriendName is now your friend.',
                  newFriendIconLink,
                );
          }
        });
  }

  Widget buildFriendCard(String friendUID) {
    final profile = ref.watch(friendProfilesProvider)[friendUID];
    return Card(
      elevation: 3.0,
      child: Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              profile?.iconLink ??
                  'https://images.pexels.com/photos/2071882/pexels-photo-2071882.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500))',
            ),
          ), // a cat image
          SizedBox(height: 10),
          Text(
            profile?.name ?? 'Username',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            profile?.bio ?? 'Bio',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 5),

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
    if (ref.watch(unreadNotificationProvider) > 0){
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
    }
      
    else {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Friends'), actions: [
         buildNotificationButton()
        ],
      ),
      //horizontal scroll
      body: friendList.isEmpty
          ? Center(child: Text("Let's add friends by pressing + button"))
          : PageView.builder(
          physics: const BouncingScrollPhysics(),
          controller: PageController(viewportFraction: 0.8),
          itemCount: friendList.length,
          itemBuilder: (context, index) {
            final friendUID = friendList[index];
            return Padding(
          padding: const EdgeInsets.all(8.0),
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
