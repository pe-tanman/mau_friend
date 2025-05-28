import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:home_widget/home_widget.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:mau_friend/providers/emergency_provider.dart';
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

    if (ref.read(emergencyProvider.notifier).isEmergencyActive()) {
      return UserStatus('🚨', 'feeling unsafe');
    }

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

  void startTrackingLocation() {
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

    Geolocator.getPositionStream(locationSettings: locationSettings).listen((
      Position? position,
    ) {
      if (position == null) {
        return;
      }
      final myLocations = ref.read(locationsProvider);
      updateMyStatus(position, myLocations);
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
    if (!notificationPermission) {
      await Permission.notification.request();
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      await FirebaseMessaging.instance.subscribeToTopic("arrival");
      // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
      //pass unique device token
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        print("APNs Token: $apnsToken");
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
   

    FirestoreHelper().addMessage(
      'Arrival',
      '${senderName} is now in $status',
      senderImageUrl,
      'Arrival',
      receivers
    );
  } //keep user's basic profile

  Future<void> updateMyStatus(
    Position position,
    List<RegisteredLocation> myLocations,
  ) async {
    final currentLocation = LatLng(position.latitude, position.longitude);
    //save in firebase and riverpod
    var status = await userStatus(currentLocation, position.speed, myLocations);
    if (status.icon == state.icon && status.status == state.status) {
      return;
    } else {
      state = status;
      RealtimeDatabaseHelper dbHelper = RealtimeDatabaseHelper();
      final notificationEnabledLocations =
          await PrefsHelper().getLocationNotificationPrefs();

      if (notificationEnabledLocations.contains(status.status)) {
        sendArrivalNotification(status.status);
      }

      await dbHelper.updateStatus(status);
    }
  }
}

final myStatusProvider = NotifierProvider<MyStatusProvider, UserStatus>(
  MyStatusProvider.new,
);
