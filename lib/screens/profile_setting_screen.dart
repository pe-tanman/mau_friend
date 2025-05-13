import 'package:flutter/material.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';

class ProfileSettingScreen extends ConsumerStatefulWidget {
  static const routeName = '/profile-setting';
  @override
  _ProfileSettingScreenState createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends ConsumerState<ProfileSettingScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _selectedIcon;
  late File iconImage;
  bool setImage = false;
  bool isLoading = false;
  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _usernameController.text = profile.name ?? '';
    _bioController.text = profile.bio ?? '';
    _selectedIcon = profile.iconLink;
  }

  Future<void> _saveProfileSettings() async {
    
    setState(() {
      isLoading = true;
    });
    String username = _usernameController.text;
    String bio = _bioController.text;
    String userUID = FirebaseAuth.instance.currentUser!.uid;

    //upload icon image
    String uploadPath = 'users/$userUID/icon.png';

    String iconLink = await StorageHelper().uploadFile(uploadPath, iconImage);

    //save to firestore
    await FirestoreHelper().addUserProfile(userUID, username, bio, iconLink);
    ref.read(profileProvider.notifier).loadMyProfile();
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
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
      var targetSize = 300000; //300KB
      if (originalSize > targetSize) {
        var quality = ((targetSize / originalSize) * 100).toInt();
        List<int> compressedImage = (await FlutterImageCompress.compressWithFile(
          path,
          minWidth: 500,
          minHeight: 500,
          quality: quality,
        )) as List<int>;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings'),
        actions: [
          ElevatedButton(onPressed: _saveProfileSettings, child: isLoading? CircularProgressIndicator() :Text('Save')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
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
                      'https://images.pexels.com/photos/2071882/pexels-photo-2071882.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                ),
              ), // a
            ],
              if (setImage) ...[
                SizedBox(width: 30),

                SizedBox(
                  height: 100,
                  width: 100,
                  child: ClipOval(
                    child: Image.file(
                      iconImage,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 40),
              TextField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            
          ],
        ),
      ),
    );
  }
}
