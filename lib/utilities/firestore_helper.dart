import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/my_status_provider.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a document to a collection
  Future<void> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collectionPath).add(data);
    } catch (e) {
      print('Error adding document: $e');
      rethrow;
    }
  }

  // Get all documents from a collection
  Future<Map<String, dynamic>> getUserProfile(String userUID) async {
    try {
      final userDoc =
          await _firestore.collection('userProfiles').doc(userUID).get();

      return userDoc.data() ?? {};
    } catch (e) {
      print('Error getting documents: $e');
      rethrow;
    }
  }

  Future<void> addUserProfile(
    String userUID,
    String? username,
    String? bio,
    String? iconLink,
  ) async {
    try {
      var data = {
        'userUID': userUID,
        'username': username,
        'bio': bio,
        'iconLink': iconLink,
      };
      await _firestore.collection('userProfiles').doc(userUID).set(data);
    } catch (e) {
      print('Error adding user profile: $e');
      rethrow;
    }
  }

  Future<void> deleteUserProfile(String userUID) async {
    await _firestore.collection('userProfiles').doc(userUID).delete;
  }

  Future<void> updatePassword(String userUID, String password) async {
    await _firestore.collection('userPasswords').doc(userUID).set({
      'password': password,
    });
  }

  Future<String> getPassword(String userUID) async {
    try {
      final passwordDoc =
          await _firestore.collection('userPasswords').doc(userUID).get();
      return passwordDoc.data()?['password'] ?? '';
    } catch (e) {
      print('Error getting password: $e');
      rethrow;
    }
  }

  Future<void> addFriendList(String friendUID) async {
    var myUID = FirebaseAuth.instance.currentUser!.uid;
    final myProfile = await getUserProfile(myUID);
    final friendProfile = await getUserProfile(friendUID);
    //update my firestore
    try {
      await _firestore.collection('friendList').doc(myUID).set({
        'friendList': FieldValue.arrayUnion([friendUID]),
      }, SetOptions(merge: true));
      await _firestore.collection('friendList').doc(myUID).set({
        'profiles': {friendUID: friendProfile},
      }, SetOptions(merge: true));

      //update friend's firestore
      await _firestore.collection('friendList').doc(friendUID).set({
        'friendList': FieldValue.arrayUnion([myUID]),
      }, SetOptions(merge: true));
      await _firestore.collection('friendList').doc(friendUID).set({
        'profiles': {myUID: myProfile},
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding friend: $e');
      rethrow;
    }
  }

  Future<List<String>> getFriendList() async {
    var myUID = FirebaseAuth.instance.currentUser!.uid;
    try {
      final friendListDoc =
          await _firestore.collection('friendList').doc(myUID).get();
      List<String> friendList = List<String>.from(
        friendListDoc.data()?['friendList'] ?? [],
      );
      return friendList;
    } catch (e) {
      print('Error getting friend list: $e');
      rethrow;
    }
  }

  Future<void> deleteFriendList() async {
    var myUID = FirebaseAuth.instance.currentUser!.uid;
    await _firestore.collection('friendList').doc(myUID).delete();
  }

  Future<void> removeFriend(String friendUID) async {
    var myUID = FirebaseAuth.instance.currentUser!.uid;
    try {
      await _firestore.collection('friendList').doc(myUID).update({
        'friendList': FieldValue.arrayRemove([friendUID]),
      });
      await _firestore.collection('friendList').doc(friendUID).update({
        'friendList': FieldValue.arrayRemove([myUID]),
      });
    } catch (e) {
      print('Error removing friend: $e');
      rethrow;
    }
  }

  Future<Map> getFriendProfiles() async {
    try {
      String myUID = FirebaseAuth.instance.currentUser!.uid;
      final friendDoc =
          await _firestore.collection('friendList').doc(myUID).get();
      var data = friendDoc.data();
      var result = data!['profiles'];
      return result;
    } catch (e) {
      print('Error loading friend profiles: $e');
      rethrow;
    }
  }

  Future<void> removeFriendProfile(String friendUID) async {
    var myUID = FirebaseAuth.instance.currentUser!.uid;
    try {
      await _firestore.collection('friendList').doc(myUID).update({
        'profiles': {friendUID: FieldValue.delete()},
      });
      await _firestore.collection('friendList').doc(friendUID).update({
        'profiles': {myUID: FieldValue.delete()},
      });
    } catch (e) {
      print('Error removing friend profile: $e');
      rethrow;
    }
  }
}

class StorageHelper {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a file to Firebase Storage
  Future<String> uploadFile(String uploadPath, File file) async {
    try {
      final ref = _storage.ref().child(uploadPath);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  // Download a file from Firebase Storage
  Future<void> downloadFile(String url, String localPath) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.writeToFile(File(localPath));
    } catch (e) {
      print('Error downloading file: $e');
      rethrow;
    }
  }
}

class RealtimeDatabaseHelper {
  FirebaseDatabase database = FirebaseDatabase.instance;

  Future<void> updateStatus(UserStatus status) async {
    var userUID = FirebaseAuth.instance.currentUser!.uid;
    await database.ref('users/$userUID').set({
      'icon': status.icon,
      'status': status.status,
    });
  }

  Future<void> deleteStatus() async {
    var userUID = FirebaseAuth.instance.currentUser!.uid;
    await database.ref('users/$userUID').remove();
  }
}
