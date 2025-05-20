import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:mau_friend/providers/locations_provider.dart';
import 'package:mau_friend/utilities/statics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/providers/my_status_provider.dart';

import 'package:location/location.dart' as loc;

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
  loc.Location location = loc.Location();

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

  Future<void> initLocationSetting() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    var backgroundPermission = await location.isBackgroundModeEnabled();

    if (!serviceEnabled) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    if (permission == LocationPermission.denied) {
      print('asking permission');
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    // if (!backgroundPermission) {
    //   await location.enableBackgroundMode();
    // }
  }

  Future<loc.LocationData> getCurrentPosition() async {
    final currentPosition = await location.getLocation();
    return currentPosition;
  }

  //keep user's basic profile
  void updateMyStatus(
    loc.LocationData position,
    List<RegisteredLocation> myLocations
  ) {
    final currentLocation = LatLng(position.latitude!, position.longitude!);
    //save in firebase and riverpod
    userStatus(currentLocation, position.speed!, myLocations).then((value) {
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
