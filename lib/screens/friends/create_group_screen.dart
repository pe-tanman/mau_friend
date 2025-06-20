import 'package:flutter/material.dart';
import 'package:mau_friend/providers/group_profiles_provider.dart';

import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/screens/home_screen.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mau_friend/utilities/statics.dart';

import 'dart:io';

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const routeName = '/create-group';
  const CreateGroupScreen({super.key});
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  String? _selectedIcon;
  File? iconImage;
  String? groupId;
  bool setImage = false;
  bool isLoading = false;
  bool isDeleteLoading = false;
  bool isNewGroup = true;
  List<String> members = [];
  Map<String, Profile> profiles = {};
  bool isInit = true;

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> saveGroupSettings() async {
    setState(() {
      isLoading = true;
    });
    String groupName = _groupNameController.text;

    //upload icon image
    String uploadPath = 'users/$groupName/icon.png';
    String iconLink = '';

    if (iconImage != null) {
      iconLink = await StorageHelper().uploadFile(uploadPath, iconImage!);
    } else {
      iconLink = _selectedIcon ?? '';
    }

    //reload group profiles

    //save to firestore
    await FirestoreHelper().addToGroup(
      groupId: groupId!,
      groupName: groupName,
      groupIconLink: iconLink,
      memberList: members,
      memberProfiles: profiles,
    );
    print('saved');

    setState(() {
      isLoading = false;
    });
    if (isNewGroup) {
      Navigator.of(context).pushNamed(HomeScreen.routeName);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectIcon() async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      var path = result.files.single.path!;
      var originalIconImage = File(path);

      //compress image
      var originalSize = originalIconImage.lengthSync();
      var targetSize = 1000000; //1MB
      if (originalSize > targetSize) {
        var quality = ((targetSize / originalSize) * 100).toInt();
        List<int> compressedImage =
            (await FlutterImageCompress.compressWithFile(
                  path,
                  minWidth: 480,
                  minHeight: 480,
                  quality: quality,
                ))
                as List<int>;
        iconImage = File(path)..writeAsBytesSync(compressedImage);
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String compressedPath = '${appDocDir.path}/compressed_icon.png';
        await File(compressedPath).writeAsBytes(compressedImage);
        iconImage = File(compressedPath);
      } else {
        iconImage = originalIconImage;
      }
      setState(() {
        setImage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        groupId =
            args['groupId'] ?? DateTime.now().millisecondsSinceEpoch.toString();
        isNewGroup = args['isNewGroup'] ?? true;
        members = args['selectedMembers'] ?? [];
        members.add(ref.read(profileProvider).userUID);
        profiles[ref.read(profileProvider).userUID] = ref.read(profileProvider);
      }
      if (isNewGroup) {
        _groupNameController.text = '';
        _selectedIcon = null;
        groupId = DateTime.now().millisecondsSinceEpoch.toString();
      } else {
        final groupProfile = ref.read(groupProfilesProvider)[groupId];
        _groupNameController.text = groupProfile?.name ?? '';
        _selectedIcon = groupProfile?.iconLink;
      }

      profiles = {...profiles, ...ref.watch(friendProfilesProvider)};
      setState(() {
        isInit = false;
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
        actions: [
          ElevatedButton(
            onPressed: saveGroupSettings,
            child: isLoading ? CircularProgressIndicator() : Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Icon', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: _selectIcon,
                    icon: Icon(Icons.add_a_photo_outlined),
                    label: Text('Choose Image'),
                  ),
                ],
              ),

              if (_selectedIcon != null && !setImage) ...[
                SizedBox(width: 10),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    _selectedIcon ??
                        Statics.defaultIconLink, // default icon link
                  ),
                ),
              ],
              if (setImage) ...[
                SizedBox(width: 30),

                SizedBox(
                  height: 100,
                  width: 100,
                  child: ClipOval(
                    child:
                        (iconImage != null)
                            ? Image.file(
                              iconImage!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                ),
              ],
              SizedBox(height: 30),
              SizedBox(
                height: 400,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final profile = profiles[member];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            profile?.iconLink != null
                                ? NetworkImage(profile!.iconLink!)
                                : NetworkImage(Statics.defaultIconLink),
                      ),
                      title: Text(profile?.name ?? 'Unknown'),
                    );
                  },
                  itemCount: members.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
