import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mau_friend/providers/group_profiles_provider.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/screens/friends/emergency_location_screen.dart';
import 'package:mau_friend/screens/friends/friend_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mau_friend/screens/friends/add_friends/add_friend_screen.dart';
import 'package:mau_friend/screens/groups/group_setting_screen.dart';
import 'package:mau_friend/utilities/custom_widget_info.dart';
import 'package:mau_friend/utilities/database_helper.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/utilities/prefs_helper.dart';
import 'package:mau_friend/utilities/statics.dart';
import 'package:mau_friend/providers/friend_list_provider.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  static String routeName = '/group-detail';
  const GroupDetailScreen({Key? key}) : super(key: key);

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  List memberList = [];
  List profileList = [Profile];
  String userState = 'offline';
  late StreamSubscription friendsSubscription;
  late StreamSubscription statusSubscription;

  late DatabaseReference dbRef;
  Map statusMap = {};
  bool isLoading = true;
  bool isInit = true;
  bool isUnreadLoading = true;
  String groupId = '';
  late GroupProfile groupProfile;

  String? imagePath;

  Map locationAvailableMap = {};

  Future<void> updateMemberStatus(String memberUID) async {
    final event =
        await FirebaseDatabase.instance.ref('users/$memberUID').once();
    final map = event.snapshot.value;
    if (map != null) {
      setState(() {
        statusMap[memberUID] = map;
      });
    } // Update home widget with first friend
  }

  Future<void> updateLocationAvailable(String memberUID) async {
    final location = await FirestoreHelper().getEmergencyLocation(memberUID);
    setState(() {
      locationAvailableMap[memberUID] = location != null;
    });
  }

  @override
  void initState() {
    super.initState();
    BackgroundFetch.start()
        .then((int status) {
          print('[BackgroundFetch] start success: $status');
        })
        .catchError((e) {
          print('[BackgroundFetch] start FAILURE: $e');
        });

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
    groupId = ref.read(currentGroupIdProvider);
   
    friendsSubscription = FirebaseFirestore.instance
        .collection('groupMemberList')
        .doc(groupId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            var groupMap = snapshot.data();
            memberList = groupMap?['members'] ?? [];
            memberList.remove(FirebaseAuth.instance.currentUser?.uid);
            profileList = groupMap?['memberProfiles'].values.toList() ?? [];
            isLoading = false;
          }
        });
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
      color: isEmergency ? Colors.red : Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    //TODO: remove this
                    int status = await BackgroundFetch.status;
                    print('[BackgroundFetch] status: $status');
                    Navigator.of(context).pushNamed(
                      FriendDetailScreen.routeName,
                      arguments:
                          friendUID, // pass the friendUID to detail screen
                    );
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      profile?.iconLink ??
                          Statics.defaultIconLink, // default icon link
                    ),
                  ),
                ), // a cat image
                SizedBox(height: 20),
                Text(
                  overflow: TextOverflow.ellipsis,
                  profile?.name ?? 'Username',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                statusMap[friendUID]?['icon'] ?? '🔴',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 160,
                                  minWidth: 50,
                                ),
                                child: Text(
                                  statusMap[friendUID]?['status'] ?? 'offline',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     groupProfile = ref.watch(groupProfilesProvider)[groupId]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(groupProfile.name ?? 'Group Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, GroupSettingScreen.routeName);
            },
          ),
        ],
      ),
      body:
          memberList.isEmpty
              ? Center(child: Text("Let's add friends by pressing + button"))
              : PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: PageController(viewportFraction: 0.8),
                itemCount: memberList.length,
                itemBuilder: (context, index) {
                  final memberUID = memberList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 40,
                    ),
                    child: buildFriendCard(memberUID),
                  );
                },
              ),
    );
  }
}
