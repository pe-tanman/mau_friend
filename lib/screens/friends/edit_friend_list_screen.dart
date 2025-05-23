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
  List friendList = [];
  bool isNotificationsLoading = true;
  bool isInit = true;
  List<String> notificationList = [];
  List<String> emergencyList = [];

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
    final prefs = await SharedPreferences.getInstance();
    notificationList =
        prefs.getStringList('notificationList') ?? [];
    emergencyList =
        prefs.getStringList('emergencyList') ?? [];
    setState(() {
      isNotificationsLoading = false;
    });
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
            icon:
                (notificationList.contains(friendUID))
                    ?  Icon(
                      Icons.notifications_active,
                      color: Theme.of(context).colorScheme.primary,
                    )
                    : const Icon(
                      Icons.notifications_off_outlined,
                      color: Colors.grey,
                    ),
            onPressed: () {
              setState(() {
                if (notificationList.contains(friendUID)) {
                  notificationList.remove(friendUID);
                  PrefsHelper().removeNotificationPrefs(friendUID);
                  
                } else {
                  notificationList.add(friendUID);
                  PrefsHelper().addNotificationPrefs(friendUID);
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.emergency, color: (emergencyList.contains(friendUID)) ? Colors.red : Colors.grey),
            onPressed: () {
              setState(() {
                int emergencyCount = emergencyList.length;
                if (emergencyList.contains(friendUID)) {
                  emergencyList.remove(friendUID);
                  PrefsHelper().removeEmergencyPrefs(friendUID);
                } else {
                  if(emergencyCount >= 3) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You can only add 3 emergency contacts.'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  else{
emergencyList.add(friendUID);
                    PrefsHelper().addEmergencyPrefs(friendUID);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'You can add up to another ${3 - emergencyCount - 1} emergency contacts.',
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                  
                }
              });
            },
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
              : (isNotificationsLoading) ? Center(child: CircularProgressIndicator()) : ListView.builder(
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
