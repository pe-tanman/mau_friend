import 'package:firebase_auth/firebase_auth.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:mau_friend/providers/locations_provider.dart';
import 'package:mau_friend/utilities/location_helper.dart';
import 'package:mau_friend/utilities/statics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/utilities/location_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/providers/my_status_provider.dart';
import 'package:geocoding/geocoding.dart';

@riverpod
class MyStatusProvider extends Notifier<UserStatus> {
  @override
  UserStatus build() => UserStatus('🔴', 'Online');

 Position? prevPosition;

  List velocityList = [];

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
    } else if (averageVelocityKmPerHour() > 6) {
      return UserStatus('🚴‍♂️', 'Moving');
    } else if (averageVelocityKmPerHour() > 2) {
      return UserStatus('🚶‍♂️', 'Moving');
    }
    return UserStatus('🟢', 'online');
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

  //keep user's basic profile
  void updateMyStatus(Position position) {
    if (prevPosition != null) {
      velocityList.add(velocity(prevPosition!, position));
    }
    final currentLocation = LatLng(position.latitude, position.longitude);

    List<RegisteredLocation> myLocations = ref.read(locationsProvider);
    //save in firebase and riverpod
    userStatus(currentLocation, myLocations).then((value) {
      if (value.icon == state.icon && value.status == state.status) {
        return;
      } else {
        RealtimeDatabaseHelper dbHelper = RealtimeDatabaseHelper();
        dbHelper.updateStatus(value).then((_) {
          state = value;
        });
      }
      prevPosition = position;
    });
  }
}

final myStatusProvider = NotifierProvider<MyStatusProvider, UserStatus>(
  MyStatusProvider.new,
);
