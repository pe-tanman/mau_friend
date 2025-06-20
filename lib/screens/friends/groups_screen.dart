import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  List<String> joinedGroups = [];
  List<String> createdGroups = [];

  @override
  Future<void> initState() async {
    super.initState();
    final profile = await FirestoreHelper().getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              index == 0
                  ? 'Joined Groups'
                  : index == joinedGroups.length + 1
                  ? 'Created Groups'
                  : '',
            ),
            subtitle:
                index == 0
                    ? Text(
                      joinedGroups.isEmpty
                          ? 'No joined groups'
                          : joinedGroups[index - 1],
                    )
                    : index == joinedGroups.length + 1
                    ? Text(
                      createdGroups.isEmpty
                          ? 'No created groups'
                          : createdGroups[index - joinedGroups.length - 2],
                    )
                    : null,
            onTap: () {
              // Handle group tap
            },
          );
        },
        itemCount: joinedGroups.length + createdGroups.length + 2,
      ),
    );
  }
}
