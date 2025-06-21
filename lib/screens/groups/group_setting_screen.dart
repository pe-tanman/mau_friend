import 'package:flutter/material.dart';
import 'package:mau_friend/screens/groups/add_member_group_screen.dart';
import 'package:mau_friend/screens/groups/create_group_screen.dart';

class GroupSettingScreen extends StatelessWidget {
  const GroupSettingScreen({Key? key}) : super(key: key);
  static const routeName = '/group-setting';

  void _invitePeople(BuildContext context) {
    Navigator.pushNamed(context, AddMemberGroupScreen.routeName, 
        arguments: {'isNewGroup': false});
  }

  void _groupProfileSetting(BuildContext context) {
    // Implement your group profile setting logic here.
    Navigator.pushNamed(
      context,
      CreateGroupScreen.routeName,
      arguments: {'isNewGroup': false},
    );
  }

  void _manageMembers(BuildContext context) {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person_add_outlined),
              title: const Text('Invite People'),
              onTap: () => _invitePeople(context),
            ),
            ListTile(
              leading: const Icon(Icons.account_box_outlined),
              title: const Text('Group Profile Setting'),
              onTap: () => _groupProfileSetting(context),
            ),
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: const Text('Manage Members'),
              onTap: () => _manageMembers(context),
            ),
          ],
        ),
      ),
    );
  }
}
