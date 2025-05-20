import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:mau_friend/providers/locations_provider.dart';
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
    double speedKmPH = speed * 10 / 36; //convert m/s -> km/h

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
        distanceFilter: 100,
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
      // final myLocations = r
      // ef.read(locationsProvider);
      // updateMyStatus(position, myLocations);
      print('Current position: ${position.latitude}, ${position.longitude}');
    });
  }

  Future<void> initLocationSetting() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    bool permission = await Permission.location.isGranted;
    bool permissionAlways = await Permission.locationAlways.isGranted;
    bool notificationPermission = await Permission.notification.isGranted;

    if (!serviceEnabled) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    if (!permission) {
      print('asking permission');
      await Permission.location.request();
    }
    if (!permissionAlways) {
      await Permission.locationAlways.request();
    }
    if (!notificationPermission && Platform.isAndroid) {
      await Permission.notification.request();
    }

    // if (!backgroundPermission) {
    //   await location.enableBackgroundMode();
    // }
  }

  Future<Position> getCurrentPosition() async {
    final currentPosition = await Geolocator.getCurrentPosition();
    return currentPosition;
  }

  //keep user's basic profile
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
