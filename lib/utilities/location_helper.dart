import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:mau_friend/statics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/providers/my_status_provider.dart';
import 'package:mau_friend/providers/locations_provider.dart';

class UserStatus {
  String status;
  String icon;
  UserStatus(this.icon, this.status);
}

class LocationHelper {
  late StreamSubscription<Position> positionStream;
  var prevPosition;
  var velocityList = <double>[];
  var prevStatus = UserStatus('🔴', 'offline');
  final container = ProviderContainer();

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1,
  );

  //this is temporary; in the future, we will use the background locaition
  Future<void> initLocationSetting() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }
    if (permission == LocationPermission.denied) {
      print('asking permission');
      permission = await Geolocator.requestPermission();
      print('asked permission');
      if (permission != LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
  }

  Future<void> trackLocation() async {
    positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position? position) {
      if (position == null) {
        return;
      }
      var currentLocation = LatLng(position.latitude, position.longitude);

      if (prevPosition != null) {
        velocityList.add(velocity(prevPosition, position));
      }

      List<RegisteredLocation> myLocations = container.read(locationsProvider);
      //save in firebase and riverpod
      userStatus(currentLocation, myLocations).then((value) {
        if (value.icon == prevStatus.icon &&
            value.status == prevStatus.status) {
          return;
        }
        else{
           RealtimeDatabaseHelper dbHelper = RealtimeDatabaseHelper();
          dbHelper.updateStatus(value);
          container.read(myStatusProvider.notifier).updateMyStatus(value);
        }
       

        prevStatus = value;
      });
      
      prevPosition = position;
    });
  }

  void dispose() {
    container.dispose();
    positionStream.cancel();
  }

  Future<UserStatus> userStatus(
    LatLng currentLocation,
    List<RegisteredLocation> myLocations,
  ) async {
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
    if (averageVelocityKmPerHour() > 60) {
      return UserStatus('🚃', 'Moving');
    } else if (averageVelocityKmPerHour() > 20) {
      return UserStatus('🚗', 'Moving');
    } else if (averageVelocityKmPerHour() > 5) {
      return UserStatus('🚴‍♂️', 'Moving');
    } else if (averageVelocityKmPerHour() > 0.5) {
      return UserStatus('🚶‍♂️', 'Moving');
    }
    return UserStatus('🔴', 'offline');
  }

  double velocity(Position previousPosition, Position currentPosition) {
    // Calculate the time difference in seconds
    double timeDifference =
        currentPosition.timestamp
            .difference(previousPosition.timestamp)
            .inSeconds
            .toDouble();

    if (timeDifference == 0) {
      return 0.0; // Avoid division by zero
    }

    // Calculate the distance in meters
    double distance = Geolocator.distanceBetween(
      previousPosition.latitude,
      previousPosition.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    // Calculate speed in meters per second
    return distance / timeDifference;
  }

  double averageVelocityKmPerHour() {
    double sum = 0;
    double average = 0;
    if (velocityList.length > 20) {
      for (double v in velocityList.sublist(
        velocityList.length - 20,
        velocityList.length - 1,
      )) {
        sum += v;
      }
      average = sum / 20;
    } else {
      for (double v in velocityList) {
        sum += v;
      }
      average = sum / velocityList.length;
    }
    return average * 3.6;
  }
}
