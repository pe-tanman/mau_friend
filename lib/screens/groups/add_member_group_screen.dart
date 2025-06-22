import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/friend_list_provider.dart';
import 'package:mau_friend/providers/group_profiles_provider.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/screens/groups/create_group_screen.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/utilities/statics.dart';

class AddMemberGroupScreen extends ConsumerStatefulWidget {
  static const routeName = '/add-member-group';
  const AddMemberGroupScreen({Key? key}) : super(key: key);

  @override
  _AddMemberGroupScreenState createState() => _AddMemberGroupScreenState();
}

class _AddMemberGroupScreenState extends ConsumerState<AddMemberGroupScreen> {
  List<String> selectedMembers = [];
  bool isNextPushed = false;
  bool isNewGroup = true;

  @override
  void initState() {
    super.initState();
    final currentGroupId = ref.read(currentGroupIdProvider);
    if (ref.read(groupProfilesProvider).keys.contains(currentGroupId)) {
      selectedMembers =
          ref.read(groupProfilesProvider)[currentGroupId]?.memberList ?? [];
      print('members: ${ref.read(groupProfilesProvider)[currentGroupId]?.memberList}');
      print(
        'current name: ${ref.read(groupProfilesProvider)[currentGroupId]?.name}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(friendProfilesProvider);
    final friendList = ref.watch(friendListProvider);
    final arguments = ModalRoute.of(context)?.settings.arguments;
    isNewGroup = arguments != null && arguments is Map && arguments['isNewGroup'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Members'),
        actions: [
          TextButton(
            child: isNewGroup ? Text('Next') : Text('Save'),
            onPressed:
                (selectedMembers.isNotEmpty)
                    ? () {
                      //場合は存在するグループにメンバーを追加するときか、グループを新規作成するとき
                      if (isNextPushed) return;
                      isNextPushed = true;
                      selectedMembers.add(
                        FirebaseAuth.instance.currentUser!.uid,
                      );
                      if (isNewGroup) {
                         final newGroupId =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        ref
                            .read(groupProfilesProvider.notifier)
                            .addGroupMembers(newGroupId, selectedMembers);
                        ref
                            .read(currentGroupIdProvider.notifier)
                            .setCurrentGroupId(newGroupId);
                           Navigator.pushNamed(
                          context,
                          CreateGroupScreen.routeName,
                          arguments: {'isNewGroup': true},
                        );
                      
                      } else {
                          ref
                            .read(groupProfilesProvider.notifier)
                            .addGroupMembers(
                              ref.read(currentGroupIdProvider),
                              selectedMembers,
                            );
                            Map<String, Profile> memberProfiles = {};
                            for (final member in selectedMembers) {
                              memberProfiles[member] = profiles[member]!;
                            }

                          FirestoreHelper().addToGroup(
                            groupId: ref.read(currentGroupIdProvider),
                            memberList: selectedMembers,
                            memberProfiles: memberProfiles,
                          );
                          Navigator.pop(context);
                          print('saved group members');

                      }
                    }
                    : null,
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
            trailing:
                isSelected
                    ? Icon(
                      Icons.check_box,
                      color: Theme.of(context).primaryColor,
                    )
                    : Icon(Icons.check_box_outline_blank),
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
