import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/friend_list_provider.dart';
import 'package:mau_friend/providers/notification_provider.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/themes/app_color.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/utilities/prefs_helper.dart';
import 'package:mau_friend/utilities/statics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditFriendListScreen extends ConsumerStatefulWidget {
  static const String routeName = '/edit-friend-list';
  const EditFriendListScreen({Key? key}) : super(key: key);

  @override
  _EditFriendListScreenState createState() => _EditFriendListScreenState();
}

class _EditFriendListScreenState extends ConsumerState<EditFriendListScreen> {
  Map<String, Profile> friendProfiles = {};
  List<String> friendList = [];
  bool isNotificationsLoading = true;
  bool isInit = true;
  List<String> notificationList = [];
  List<String> emergencyList = [];
  List<String> muteList = [];
  bool isInitDialog = true;
  @override
  void initState() {
    loadNotificationPrefs();
    
    super.initState();
  }

  void removeFriend(String friendUID) {
    FirestoreHelper().removeFriend(friendUID);
    FirestoreHelper().removeFriendProfile(friendUID);
    ref
        .read(notificationProvider.notifier)
        .addNotification(
          '${friendProfiles[friendUID]!.name} is removed from your friend list.',
          friendProfiles[friendUID]!.iconLink!,
        );
  }

  Future<void> loadNotificationPrefs() async {

    final myToken = await FirebaseMessaging.instance.getToken();
    print('mytoken: $myToken');
    print('Loading notification preferences...');
    notificationList = await PrefsHelper().getNotificationPrefs();
    emergencyList = await PrefsHelper().getEmergencyPrefs();
    muteList = await PrefsHelper().getMutePrefs();
    
    setState(() {
      isNotificationsLoading = false;
    });
  }

  Widget _buildSettingDialog(index) {
    final friendUID = friendList[index];
    return StatefulBuilder(
      builder: (context, setState) {
        return SimpleDialog(
          title: Text('Notification Settings'),
            children: [
              CheckboxListTile(
                title: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        muteList.contains(friendUID)
                            ? Colors.purple.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        muteList.contains(friendUID)
                            ? Icons.notifications_off
                            : Icons.notifications_outlined,
                        color:
                            muteList.contains(friendUID)
                                ? Colors.purple
                                : Colors.grey,
                      ),
                      Text(
                        'Mute',
                        style: TextStyle(
                          color:
                              muteList.contains(friendUID)
                                  ? Colors.purple
                                  : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                value: muteList.contains(friendUID),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      if (!muteList.contains(friendUID)) {
                        print('Adding $friendUID to mute list');
                        muteList.add(friendUID);
                        PrefsHelper().addMutePrefs(friendUID);
                        FirestoreHelper().addMutedList(
                          friendUID
                        );
                      }
                    } else {
                      if (muteList.contains(friendUID)) {
                        muteList.remove(friendUID);
                        PrefsHelper().removeMutePrefs(friendUID);
                        FirestoreHelper().removeMutedList(
                          friendUID
                        );
                      }
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        notificationList.contains(friendUID)
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.send,
                        color:
                            notificationList.contains(friendUID)
                                ? Colors.blue
                                : Colors.grey,
                      ),
                      Text(
                        'Notify Arrival',
                        style: TextStyle(
                          color:
                              notificationList.contains(friendUID)
                                  ? Colors.blue
                                  : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                value: notificationList.contains(friendUID),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      if (!notificationList.contains(friendUID)) {
                        notificationList.add(friendUID);
                        PrefsHelper().addNotificationPrefs(friendUID);
                      }
                    } else {
                      if (notificationList.contains(friendUID)) {
                        notificationList.remove(friendUID);
                        PrefsHelper().removeNotificationPrefs(friendUID);
                      }
                    }
                  });
                },
              ),
CheckboxListTile(

                title: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        emergencyList.contains(friendUID)
                            ? Colors.red.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emergency,
                        color:
                            emergencyList.contains(friendUID)
                                ? Colors.red
                                : Colors.grey,
                      ),
                      Text(
                        'Emergency Location',
                        style: TextStyle(
                          color:
                              emergencyList.contains(friendUID)
                                  ? Colors.red
                                  : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                value: emergencyList.contains(friendUID),
                onChanged: (value) {
                  if (value == true) {
                    if (emergencyList.length >= 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'You can only add 3 emergency contacts.',
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      if (!emergencyList.contains(friendUID)) {
                        setState(() {
                          emergencyList.add(friendUID);
                          PrefsHelper().addEmergencyPrefs(friendUID);
                        });
                      }
                    }
                  } else {
                    if (emergencyList.contains(friendUID)) {
                      setState(() {
                        emergencyList.remove(friendUID);
                        PrefsHelper().removeEmergencyPrefs(friendUID);
                      });
                    }
                  }
                },
              ),
            ],
          );
      }
        );
      }

  Widget _buildListTile(int index) {
    final friendUID = friendList[index];
    final friend = friendProfiles[friendUID];

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          friend?.iconLink ?? Statics.defaultIconLink,
        ),
      ),
      title: Text(friend?.name ?? 'username'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  return _buildSettingDialog(index);
                },
              );
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    friendProfiles = ref.watch(friendProfilesProvider);
    friendList = ref.watch(friendListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Friend List')),
      body:
          (friendList.isEmpty)
              ? Center(child: Text('No friend added'))
              : (isNotificationsLoading)
              ? Center(child: CircularProgressIndicator())
              : ReorderableListView.builder(
                 onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final String friend = friendList.removeAt(oldIndex);
           friendList.insert(newIndex, friend);
          FirestoreHelper().updateFriendList(friendList);
          
          if(newIndex == 0) {
            FirestoreHelper().addFirstFriendToken(friend);
            FirestoreHelper().removeFirstFriendToken(friendList[1]);

          }
          if(oldIndex == 0){
            FirestoreHelper().removeFirstFriendToken(friend);
            FirestoreHelper().addFirstFriendToken(friendList[0]);
          }
         
        });},
                itemBuilder: (context, index) {
                  final friendUID = friendList[index];

                  return Dismissible(
                    key: ValueKey(friendUID),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      removeFriend(friendUID);
                      
                    },
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text(
                                'Are you sure you want to remove this friend?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    child: _buildListTile(index),
                  );
                },
                itemCount: friendList.length,
              ),
    );
  }
}
