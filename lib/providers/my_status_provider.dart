import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:mau_friend/providers/locations_provider.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/utilities/prefs_helper.dart';
import 'package:mau_friend/utilities/statics.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/providers/my_status_provider.dart';

class UserStatus {
  String status;
  String icon;
  UserStatus(this.icon, this.status);
}

@riverpod
class MyStatusProvider extends Notifier<UserStatus> {
  late var locations;
  @override
  UserStatus build() {
    return UserStatus('🔴', 'Online');
  }

  Position? prevPosition;

  Future<UserStatus> userStatus(
    LatLng currentLocation,
    double speed,
    List<RegisteredLocation> myLocations,
  ) async {
    double speedKmPH = speed; //speed maybe in km/h

    if (currentLocation.latitude == Statics.initLocation.latitude &&
        currentLocation.longitude == Statics.initLocation.longitude) {
      return UserStatus('🔴', 'offline');
    }

    for (var location in myLocations) {
      double distance = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        location.coordinates.latitude,
        location.coordinates.longitude,
      );
      if (distance < location.radius) {
        return UserStatus(
          location.icon,
          location.name,
        ); //in the future, we will use "status"
      }
    }
    if (speedKmPH > 60) {
      return UserStatus('🚃', 'Moving');
    } else if (speedKmPH > 20) {
      return UserStatus('🚗', 'Moving');
    } else if (speedKmPH > 6) {
      return UserStatus('🚴‍♂️', 'Moving');
    } else if (speedKmPH > 2) {
      return UserStatus('🚶‍♂️', 'Moving');
    }
    return UserStatus('🟢', 'online');
  }

  void startTrackingLocation()  {
    LocationSettings locationSettings;
    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "Location Service is running",
          notificationText: 'mau is updating your status',
        ),
      );
    } else if (Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    } else {
      throw UnsupportedError('Unsupported platform');
    }
    
     Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position? position) {
      if (position == null) {
        return;
      }
      final myLocations = ref.read(locationsProvider);
      updateMyStatus(position, myLocations);
      print('Current speed: ${position.speed}');
    });
  }

  Future<void> initLocationSetting() async {
    bool permission = await Permission.location.isGranted;
    bool permissionAlways = await Permission.locationAlways.isGranted;
    bool notificationPermission = await Permission.notification.isGranted;

    if (!permission) {
      print('asking permission');
      await Permission.location.request();
    }
    if (!permissionAlways) {
      await Permission.locationAlways.request();
    }
    if (!notificationPermission && Platform.isAndroid) {
      await Permission.notification.request();
      final notificationSettings = await FirebaseMessaging.instance
          .requestPermission(provisional: true);
          // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
          //pass unique device token
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        
      }
    }
  }

  Future<Position> getCurrentPosition() async {
    final currentPosition = await Geolocator.getCurrentPosition();
    return currentPosition;
  }

  Future<void> sendArrivalNotification(String status) async {
    final myProfile = ref.read(profileProvider);
    final senderImageUrl = myProfile.iconLink ?? Statics.defaultIconLink;
    final senderName = myProfile.name ?? 'username';
    final receivers = await PrefsHelper().getNotificationPrefs();
    List<String> receiverTokens = [];
    for (var receiverUID in receivers) {
      if (receiverUID.isEmpty) continue; // Skip empty tokens
      final profile = await FirestoreHelper().getUserProfile(receiverUID);
      final token = profile['fcmToken'] ?? '';
      if (token.isEmpty) continue; // Skip empty tokens
      receiverTokens.add(token);
    }
    FirestoreHelper().addMessage(
      'Arrival',
      '${myProfile.name} is now in $status',
      senderImageUrl,
      receiverTokens,
    );

    
  }  //keep user's basic profile
  void updateMyStatus(Position position, List<RegisteredLocation> myLocations) {
    final currentLocation = LatLng(position.latitude, position.longitude);
    //save in firebase and riverpod
    userStatus(currentLocation, position.speed, myLocations).then((value) {
      if (value.icon == state.icon && value.status == state.status) {
        return;
      } else {
        RealtimeDatabaseHelper dbHelper = RealtimeDatabaseHelper();
       
        dbHelper.updateStatus(value).then((_) {
          state = value;
        });
      }
    });
  }
}

final myStatusProvider = NotifierProvider<MyStatusProvider, UserStatus>(
  MyStatusProvider.new,
);
