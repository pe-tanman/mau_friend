import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mau_friend/providers/my_status_provider.dart';
import 'package:mau_friend/utilities/prefs_helper.dart';

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

  Future<void> addMutedList(String friendUID) async {
    var myUID = FirebaseAuth.instance.currentUser!.uid;
    try {
      await _firestore.collection('userProfiles').doc(myUID).set({
        'mutedList': FieldValue.arrayUnion([friendUID]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding to muted list: $e');
      rethrow;
    }
  }

  Future<void> removeMutedList(String friendUID) async {
    var myUID = FirebaseAuth.instance.currentUser!.uid;
    try {
      await _firestore.collection('userProfiles').doc(myUID).update({
        'mutedList': FieldValue.arrayRemove([friendUID]),
      });
    } catch (e) {
      print('Error removing from muted list: $e');
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

  Future<void> addEmergencyLocation(LatLng coordinates) async {
    var myUID = FirebaseAuth.instance.currentUser!.uid;
    var receivers = await PrefsHelper().getEmergencyPrefs();
    return _firestore.collection('emergency').doc(myUID).set({
      'coordinates': GeoPoint(coordinates.latitude, coordinates.longitude),
      'timestamp': FieldValue.serverTimestamp(),
      'receivers': receivers,
    }, SetOptions(merge: true));
  }

  Future<LatLng?> getEmergencyLocation(String friendUID) async {
    final emergencyDoc =
        await _firestore.collection('emergency').doc(friendUID).get();
    if (emergencyDoc.exists) {
      var data = emergencyDoc.data();
      if (data != null) {
        var timestamp = data['timestamp'];
        var receivers = data['receivers'];

        if (timestamp != null && timestamp is Timestamp) {
          // Check if the timestamp is within the last 1 hour
          if (timestamp.toDate().isBefore(
            DateTime.now().subtract(Duration(hours: 1)),
          )) {
            return null; // Data is too old, return null
          }
        }
        if (receivers != null && receivers is List) {
          // Check if the current user is in the receivers list
          var myUID = FirebaseAuth.instance.currentUser!.uid;
          if (!receivers.contains(myUID)) {
            return null; // Current user is not a receiver, return null
          }
        }
        GeoPoint geoPoint = data['coordinates'];
        return LatLng(geoPoint.latitude, geoPoint.longitude);
      }
    }
    return null;
  }

  Future<void> removeEmergencyLocation() async {
    var myUID = FirebaseAuth.instance.currentUser!.uid;
    try {
      await _firestore.collection('emergency').doc(myUID).delete();
    } catch (e) {
      print('Error removing emergency location: $e');
      rethrow;
    }
  }

  Future<void> addUserProfile(
    String userUID,
    String? username,
    String? bio,
    String? iconLink,
    String? fcmToken,
  ) async {
    try {
      var data = {
        'userUID': userUID,
        'username': username,
        'bio': bio,
        'iconLink': iconLink,
        'fcmToken': fcmToken,
      };
      await _firestore.collection('userProfiles').doc(userUID).set(data);
    } catch (e) {
      print('Error adding user profile: $e');
      rethrow;
    }
  }

  Future<void> deleteUserProfile(String userUID) async {
    await _firestore.collection('userProfiles').doc(userUID).delete();
  }

  Future<void> updatePassword(String userUID, String password) async {
    await _firestore.collection('userPasswords').doc(userUID).set({
      'password': password,
    }, SetOptions(merge: true));
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

  Future<void> updatePermanentAddress(
    String userUID,
    String permanentAddress,
  ) async {
    try {
      await _firestore.collection('userPasswords').doc(userUID).set({
        'permanentAddress': permanentAddress,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating permanent address: $e');
      rethrow;
    }
  }
  Future<String> getPermanentAddress(String userUID) async {
    try {
      final addressDoc =
          await _firestore.collection('userPasswords').doc(userUID).get();
          print('permanent address: ${addressDoc.data()}');
      return addressDoc.data()?['permanentAddress'] ?? '';
    } catch (e) {
      print('Error getting permanent address: $e');
      rethrow;
    }
  }

  Future<void> addFriendList(String friendUID) async {
    var myUID = FirebaseAuth.instance.currentUser!.uid;
    final myProfile = await getUserProfile(myUID);
    final friendProfile = await getUserProfile(friendUID);

    final oldFriendList = await getFriendList();
    if (oldFriendList == null || oldFriendList.isEmpty) {
      addFirstFriendToken(friendUID);
    }
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

  Future<void> updateFriendList(List<String> friendList) async {
    var myUID = FirebaseAuth.instance.currentUser!.uid;
    try {
      await _firestore.collection('friendList').doc(myUID).set({
        'friendList': friendList,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating friend list: $e');
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
      var result = {};
      if (data != null) {
        result = data['profiles'];
      } else {
        result = {};
      }

      return result;
    } catch (e) {
      print('Error loading friend profiles: $e');
      rethrow;
    }
  }

  Future<void> removeFriendProfile(String friendUID) async {
    var myUID = FirebaseAuth.instance.currentUser!.uid;
    try {
      //remove friend profile from my firestore
      var docRef = _firestore.collection('friendList').doc(myUID);
      var docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        Map profiles = docSnapshot.data()?['profiles'] ?? {};
        profiles.remove(friendUID);
        await docRef.update({'profiles': profiles});
      }
      //remove my profile from friend's firestore
      var friendDocRef = _firestore.collection('friendList').doc(friendUID);
      var friendDocSnapshot = await friendDocRef.get();
      if (friendDocSnapshot.exists) {
        Map profiles = friendDocSnapshot.data()?['profiles'] ?? {};
        profiles.remove(myUID);
        await friendDocRef.update({'profiles': profiles});
      }
    } catch (e) {
      print('Error removing friend profile: $e');
      rethrow;
    }
  }

  Future<void> addMessage(
    String title,
    String body,
    String imageUrl,
    List<String> receiverTokens,
  ) async {
    final senderUID = FirebaseAuth.instance.currentUser!.uid;
    try {
      await _firestore.collection('message').add({
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'senderUID': senderUID,
        'receiverTokens': receiverTokens,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding message: $e');
      rethrow;
    }
  }

  Future<void> addFirstFriendToken(String friendUID) async {
    final token = await FirebaseMessaging.instance.getToken();
      _firestore.collection('friendList').doc(friendUID).set({
        'firstFriendTokenList': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
      print('FCM token for $friendUID added successfully.');
  }
  Future<void> removeFirstFriendToken(String friendUID) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      _firestore.collection('friendList').doc(friendUID).update({
        'firstFriendTokenList': FieldValue.arrayRemove([token]),
      });
      print('FCM token for $friendUID removed successfully.');
    } else {
      print('No valid FCM token found for $friendUID');
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
