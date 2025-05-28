import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mau_friend/providers/my_status_provider.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/providers/notification_provider.dart';
import 'package:mau_friend/screens/friends/edit_friend_list_screen.dart';
import 'package:mau_friend/screens/friends/emergency_location_screen.dart';
import 'package:mau_friend/screens/friends/notification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mau_friend/screens/friends/add_friends/add_friend_screen.dart';
import 'package:mau_friend/utilities/database_helper.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/utilities/statics.dart';
import 'package:mau_friend/providers/friend_list_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late StreamSubscription statusSubscription;
  late DatabaseReference dbRef;
  Map statusMap = {};
  bool isLoading = true;

  String? imagePath;

  Map locationAvailableMap = {};

  Future<void> updatePrefs(var snapshot) async {
    //Save friend list to local storage from notifier
    print('onUpdated');
    final prefs = await SharedPreferences.getInstance();
    List<String>? localFriendList = prefs.getStringList('friendList');
    print('localFriendList: $localFriendList');

    if (localFriendList == null ||
        snapshot.data()!['friendList'].length > localFriendList.length) {
      await ref.read(friendListProvider.notifier).loadFriendList();
      //update statusMap variable
      final newFriendUID = snapshot.data()!['friendList'].last;
      updateFriendStatus(newFriendUID);
      //write prefs
      await prefs.setStringList(
        'friendList',
        snapshot.data()!['friendList'].cast<String>(),
      );

      //update notification
      final newFriend = snapshot.data()!['friendList'].last;
      final newFriendProfile = snapshot.data()?['profiles'][newFriend];
      final newFriendName = newFriendProfile?['username'] ?? 'username';
      final newFriendIconLink =
          newFriendProfile?['iconLink'] ?? Statics.defaultIconLink;
      final timestamp =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

      await NotificationDatabaseHelper().insertData(
        timestamp,
        '$newFriendName is now your friend.',
        newFriendIconLink,
      );
      ref
          .read(notificationProvider.notifier)
          .addNotification(
            '$newFriendName is now your friend.',
            newFriendIconLink,
          );
      ref.read(notificationProvider.notifier).loadNotification();
      //when friend is removed
    } else if (snapshot.data()!['friendList'].length < localFriendList.length) {
      //update local storage
      final oldFriend = localFriendList.last;
      final oldFriendProfile = await FirestoreHelper().getUserProfile(
        oldFriend,
      );
      final oldFriendName = oldFriendProfile?['username'] ?? 'username';
      final oldFriendIconLink =
          oldFriendProfile?['iconLink'] ?? Statics.defaultIconLink;
      final timestamp =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

      //update local friend list
      await ref.read(friendListProvider.notifier).loadFriendList();
      await prefs.setStringList(
        'friendList',
        snapshot.data()!['friendList'].cast<String>(),
      );
      //update notification
      await NotificationDatabaseHelper().insertData(
        timestamp,
        '$oldFriendName is removed from your friend list.',
        oldFriendIconLink,
      );
      ref.read(notificationProvider.notifier).loadNotification();
    }
  }

  Future<void> updateFriendStatus(String friendUID) async {
    final event =
        await FirebaseDatabase.instance.ref('users/$friendUID').once();
    final map = event.snapshot.value;
    if (map != null) {
      setState(() {
        statusMap[friendUID] = map;
      });
    } // Update home widget with first friend
    updateHomeWidget();
  }

  Future<void> updateLocationAvailable(String friendUID) async {
    final location = await FirestoreHelper().getEmergencyLocation(friendUID);
    setState(() {
      locationAvailableMap[friendUID] = location != null;
    });
  }

  @override
  void initState() {
    super.initState();
    NotificationDatabaseHelper().initNotificationDatabase();
    final myUID = FirebaseAuth.instance.currentUser?.uid;
    dbRef = FirebaseDatabase.instance.ref('users');
    statusSubscription = dbRef.onValue.listen((event) {
      final map = event.snapshot.value;
      if (map != null && mounted) {
        setState(() {
          isLoading = true;
          statusMap = map as Map;
          if (isLoading) {
            isLoading = false;
          }
        });
      }
    });

    friendsSubscription = FirebaseFirestore.instance
        .collection('friendList')
        .doc(myUID)
        .snapshots()
        .listen((snapshot) {
          ref.read(friendProfilesProvider.notifier).loadFriendProfiles();
          ref.read(friendListProvider.notifier).loadFriendList();
          print('Friend List Updated');
          if (snapshot.exists) {
            updatePrefs(snapshot);
          }
        });

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          updateHomeWidget();
        });
      }
    });
  }

  Future<void> updateHomeWidget() async {

    print('home widget updated');
    const AppGroupId = 'group.mau_widget';
    const String iOSWidgetName = 'mau_widget';
    final firstProfile = ref.read(friendProfilesProvider).values.first;
    final statusName = statusMap[firstProfile.userUID]?['status'] ?? 'Offline';
    final statusIcon = statusMap[firstProfile.userUID]?['icon'] ?? '🔴';
    HomeWidget.saveWidgetData<String>('username', firstProfile.name);
    HomeWidget.saveWidgetData<String>('iconLink', firstProfile.iconLink);
    HomeWidget.saveWidgetData<String>('status', '$statusIcon $statusName');
    HomeWidget.updateWidget(iOSName: iOSWidgetName);
  }

  @override
  void dispose() {
    statusSubscription.cancel();
    friendsSubscription.cancel();
    dbRef.onValue.drain();
    super.dispose();
  }

  Widget buildFriendCard(String friendUID) {
    final profile = ref.watch(friendProfilesProvider)[friendUID];
    bool isEmergency = statusMap[friendUID]?['status'] == 'feeling unsafe';
    bool isLocationLoading = true;
    if (isEmergency) {
      updateLocationAvailable(friendUID);
      isLocationLoading = locationAvailableMap[friendUID] == null;
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      elevation: 3.0,
      color: isEmergency ? Colors.red : null,
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
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          statusMap[friendUID]?['icon'] ?? '🔴',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          statusMap[friendUID]?['status'] ?? 'offline',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
          ),
          SizedBox(height: 20),
          if (locationAvailableMap[friendUID] != null &&
              locationAvailableMap[friendUID] == true)
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  EmergencyLocationScreen.routeName,
                  arguments: {'friendUID': friendUID},
                );
              },
              label: Text("View Location"),
              icon: Icon(Icons.location_on_outlined),
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
    friendList = ref.watch(
      friendListProvider,
    ); // Update home widget with first friend
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
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
      ),
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
