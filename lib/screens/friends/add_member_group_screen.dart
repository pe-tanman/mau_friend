import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/friend_list_provider.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/screens/friends/create_group_screen.dart';
import 'package:mau_friend/utilities/statics.dart';

class AddMemberGroupScreen extends ConsumerStatefulWidget {
  static const routeName = '/add-member-group';
  const AddMemberGroupScreen({Key? key}) : super(key: key);

  @override
  _AddMemberGroupScreenState createState() => _AddMemberGroupScreenState();
}

class _AddMemberGroupScreenState extends ConsumerState<AddMemberGroupScreen> {
  List<String> selectedMembers = [];
  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(friendProfilesProvider);
    final friendList = ref.watch(friendListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Members'),
        actions: [
          TextButton(
            child: Text('Next'),
            onPressed: (selectedMembers.isNotEmpty) ? () {
              Navigator.pushNamed(context, CreateGroupScreen.routeName, arguments: {
                'selectedMembers': selectedMembers,
                'isNewGroup': true,
              });
            } : null,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          final friendUid = friendList[index];
          final profile = profiles[friendUid];
          final isSelected = selectedMembers.contains(friendUid);
          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  profile?.iconLink != null
                      ? NetworkImage(profile!.iconLink!)
                      : NetworkImage(Statics.defaultIconLink),
            ),
            title: Text(profile?.name ?? 'Unknown'),
            trailing: isSelected? Icon(
              Icons.check_box,
              color: Theme.of(context).primaryColor,
            ) : Icon(Icons.check_box_outline_blank),
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedMembers.remove(friendUid);
                } else {
                  selectedMembers.add(friendUid);
                }
              });
            },
          );
        },
      ),
    );
  }
}
