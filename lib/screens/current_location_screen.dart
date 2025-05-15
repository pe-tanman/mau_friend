import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer';

import 'package:mau_friend/utilities/statics.dart';

class CurrentLocationScreen extends StatefulWidget {
  static const routeName = 'current-location-screen';
  const CurrentLocationScreen({Key? key}) : super(key: key);

  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  bool isLoading = true;
  bool isInit = true;
  LatLng currentLocation = Statics.initLocation;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1,
  );
  late StreamSubscription<Position> positionStream;

  Future<LatLng> _getCurrentLocation() async {
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

    final currentPosition = await Geolocator.getCurrentPosition();
    return LatLng(currentPosition.latitude, currentPosition.longitude);
  }

  @override
  void initState() {
    positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position? position) {
      if(position == null) {
        return;
      }
      setState(() {
        currentLocation = LatLng(
          position.latitude,
          position.longitude,
        );
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      _getCurrentLocation()
          .then((value) {
            setState(() {
              currentLocation = value;
              isLoading = false;
              
            });
          })
          .catchError((error) {
            log('Error getting location: $error');
            setState(() {
              isLoading = false;
            });
          });
          print('Current location: $currentLocation');
      isInit = false;
    }

    

    return Scaffold(
      appBar: AppBar(title: const Text('Current Location')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: Statics.initLocation, // Placeholder position
                  zoom: 2,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('currentLocation'),
                    position: currentLocation,
                    infoWindow: InfoWindow(
                      title: 'Current Location',
                      snippet:
                          'Latitude: ${currentLocation.latitude}, Longitude: ${currentLocation.longitude}',
                    ),
                  ),
                },
              ),
    );
  }
}
