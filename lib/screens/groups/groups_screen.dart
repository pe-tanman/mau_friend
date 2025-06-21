import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/group_profiles_provider.dart';
import 'package:mau_friend/screens/groups/group_detail_screen.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/utilities/statics.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  List<String> joinedGroups = [];
  List<String> createdGroups = [];
  Map groupProfiles = {};
  List<String> groupIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    ref.read(groupProfilesProvider.notifier).loadGroupProfiles().then((_) {
      setState(() {
        isLoading = false;
      });
    });
    
  }

  @override
  Widget build(BuildContext context) {
      groupProfiles = ref.watch(groupProfilesProvider);
    groupIds = groupProfiles.keys.toList() as List<String>;
    return Scaffold(
    
      body:
          (isLoading)
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    var groupId = groupIds[index];
                    var groupProfile = groupProfiles[groupId];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(groupProfile.name),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              groupProfile.iconLink != null && groupProfile.iconLink != ''
                                  ? NetworkImage(groupProfile.iconLink)
                                  : NetworkImage(Statics.defaultIconLink),
                        ),
                        onTap: () {
                          ref.read(currentGroupIdProvider.notifier).setCurrentGroupId(groupId);
                          Navigator.pushNamed(
                            context,
                            GroupDetailScreen.routeName,
                          );
                        },
                      ),
                    );
                  },
                  itemCount: groupIds.length,
                ),
              ),
    );
  }
}
