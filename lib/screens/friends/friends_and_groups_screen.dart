import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/notification_provider.dart';
import 'package:mau_friend/screens/friends/add_friends/add_friend_screen.dart';
import 'package:mau_friend/screens/friends/add_member_group_screen.dart';
import 'package:mau_friend/screens/friends/create_group_screen.dart';
import 'package:mau_friend/screens/friends/edit_friend_list_screen.dart';
import 'package:mau_friend/screens/friends/friends_screen.dart';
import 'package:mau_friend/screens/friends/groups_screen.dart';
import 'package:mau_friend/screens/friends/notification_screen.dart';
import 'package:mau_friend/utilities/database_helper.dart';
import 'package:mau_friend/utilities/prefs_helper.dart';

class FriendsAndGroupsScreen extends ConsumerStatefulWidget {
  const FriendsAndGroupsScreen({Key? key}) : super(key: key);

  @override
  _FriendsAndGroupsScreenState createState() => _FriendsAndGroupsScreenState();
}

class _FriendsAndGroupsScreenState
    extends ConsumerState<FriendsAndGroupsScreen> {
  late StreamSubscription notificationSubscription;

  @override
  void initState() {
    super.initState();
    final myUID = FirebaseAuth.instance.currentUser?.uid;
    NotificationDatabaseHelper().initNotificationDatabase();
    notificationSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .doc(myUID)
        .snapshots()
        .listen((snapshot) {
          ref.read(notificationProvider.notifier).loadNotification();
          print('Notification count updated');
          ref
              .read(unreadNotificationProvider.notifier)
              .loadUnreadNotificationCount();
        });
  }

  Widget buildNotificationButton() {
    int unread = ref.watch(unreadNotificationProvider);
    if (unread > 0) {
      return Badge.count(
        count: unread,
        child: IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            Navigator.pushNamed(context, NotificationScreen.routeName);
            ref
                .read(unreadNotificationProvider.notifier)
                .resetUnreadNotificationCount();
            PrefsHelper().updateReadNotificationPrefs(
              ref.read(notificationProvider).length,
            );
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
    return DefaultTabController(
      length: 2, // Two tabs: Friends and Groups
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contacts'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.pushNamed(context, EditFriendListScreen.routeName);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildNotificationButton(),
            ),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'Friends'), Tab(text: 'Groups')],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: const Text('Add New Contact'),
                  children: [
                    SimpleDialogOption(
                      child: Row(
                        children: [
                          const Icon(Icons.person_add, size: 24),
                          const SizedBox(width: 10),
                          const Text('Add Friend'),
                        ],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AddFriendScreen.routeName);
                      },
                    ),
                    SimpleDialogOption(
                      child: Row(
                        children: [
                          const Icon(Icons.group_add, size: 24),
                          const SizedBox(width: 10),
                          const Text('Create Group'),
                        ],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AddMemberGroupScreen.routeName, arguments: {
                          'isNewGroup': true,
                        });
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        body: TabBarView(children: [FriendsScreen(), GroupsScreen()]),
      ),
    );
  }
}
