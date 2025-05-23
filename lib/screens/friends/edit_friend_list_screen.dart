import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/friend_list_provider.dart';
import 'package:mau_friend/providers/notification_provider.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/themes/app_color.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/utilities/statics.dart';

class EditFriendListScreen extends ConsumerStatefulWidget {
  static const String routeName = '/edit-friend-list';
  const EditFriendListScreen({Key? key}) : super(key: key);

  @override
  _EditFriendListScreenState createState() => _EditFriendListScreenState();
}

class _EditFriendListScreenState extends ConsumerState<EditFriendListScreen> {
   Map<String, Profile> friendProfiles = {};
  List friendList = [];

  void removeFriend(String friendUID) {
      FirestoreHelper().removeFriend(friendUID);
      FirestoreHelper().removeFriendProfile(friendUID);
    ref.read(notificationProvider.notifier).addNotification(
      '${friendProfiles[friendUID]!.name} is removed from your friend list.',
      friendProfiles[friendUID]!.iconLink!,
    );
  }

  @override
  Widget build(BuildContext context) {
    friendProfiles = ref.watch(friendProfilesProvider);
    friendList = ref.watch(friendListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Friend List'),
      ),
      body: (friendList.isEmpty)?Center(child: Text('No friend added'),) : ListView.builder(itemBuilder: (context, index) {
        final friendUID = friendList[index];
        final friend = friendProfiles[friendUID];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(friend?.iconLink ?? Statics.defaultIconLink),
          ),
          title: Text(friend?.name ?? 'username'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text('Are you sure you want to remove this friend?'),
              actions: [
                TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
                ),
                TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  removeFriend(friendUID);
                },
                child:  Text('OK', style: TextStyle(color: Colors.red),
                ))
              ],
              ),
            ),
          ),
        );
      }, itemCount: friendList.length),
    );
  }
}