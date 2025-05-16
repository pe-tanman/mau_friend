import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/my_status_provider.dart';


class UserStatus {
  String status;
  String icon;
  UserStatus(this.icon, this.status);
}

class LocationHelper {
  late StreamSubscription<Position> positionStream;

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
      permission = await Geolocator.requestPermission();
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

  Future<Position> getCurrentPosition() async {
    final currentPosition = await Geolocator.getCurrentPosition();
    return currentPosition;
  }

  Future<void> trackLocation(WidgetRef ref) async {
    positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position? position) {
      if (position == null) {
        return;
      }
      ref.read(myStatusProvider.notifier).updateMyStatus(position);
    });
  }

  void dispose() {
    positionStream.cancel();
  }
}