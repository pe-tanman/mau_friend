import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    ref.read(profileProvider.notifier).loadUsersProfile(userUID);
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
        File compressedImage = await FlutterNativeImage.compressImage(
          originalIconImage.path,
          percentage: quality,
        );

        iconImage = compressedImage;
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
                  if (_selectedIcon != null) ...[
                    SizedBox(width: 10),
                    Text(
                      _selectedIcon!,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
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
              SizedBox(height: 20),
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
