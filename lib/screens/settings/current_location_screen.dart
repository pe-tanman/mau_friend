import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mau_friend/providers/locations_provider.dart';
import 'package:mau_friend/themes/app_color.dart';
import 'dart:developer';

import 'package:mau_friend/utilities/statics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class CurrentLocationScreen extends ConsumerStatefulWidget {
  static const routeName = 'current-location-screen';
  const CurrentLocationScreen({Key? key}) : super(key: key);

  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends ConsumerState<CurrentLocationScreen> {
  bool isLoading = true;
  bool isInit = true;
  LatLng currentLocation = Statics.initLocation;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1,
  );


  late StreamSubscription<Position> positionStream;
  Set<Marker> markers = {};
  bool isLoadingMarkers = true;

bool isDarkMode(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.dark;
}

  final darkStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8ec3b9"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1a3646"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#4b6878"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#64779e"
      }
    ]
  },
  {
    "featureType": "administrative.province",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#4b6878"
      }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#334e87"
      }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#283d6a"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6f9ba5"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#3C7680"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#304a7d"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#98a5be"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2c6675"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#255763"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#b0d5ce"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#98a5be"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#283d6a"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#3a4762"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#0e1626"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#4e6d70"
      }
    ]
  }
]''';

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
      if (position == null) {
        return;
      }
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    });
    super.initState();
  }

  Future<BitmapDescriptor> createEmojiMarker(String emoji) async {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Create a Text widget with the emoji
    textPainter.text = TextSpan(
      text: emoji,
      style: const TextStyle(
        fontSize: 50, // Adjust size as needed
      ),
    );

    textPainter.layout();
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Add padding and calculate size
    const double padding = 20.0;
    final double size = (textPainter.width > textPainter.height
            ? textPainter.width
            : textPainter.height) +
        padding * 2;

    // Add a white circle background
    final paint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2,
      paint,
    );

    // Add an outline around the circle
    final outlinePaint = Paint()
      ..color = AppColors.themeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.0;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2,
      outlinePaint,
    );

    // Draw the emoji on top of the circle
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      size.toInt(),
      size.toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  Future<void> createMyMarkers() async {
    final mylocations = ref.watch(locationsProvider);
    for (var location in mylocations) {
      final marker = Marker(
        markerId: MarkerId(location.name),
        position: LatLng(
          location.coordinates.latitude,
          location.coordinates.longitude,
        ),
        icon: await createEmojiMarker(location.icon),
        infoWindow: InfoWindow(title: location.name),
      );
      markers.add(marker);
    }
    markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: currentLocation,
        infoWindow: InfoWindow(
          title: 'Current Location',
          snippet:
              'Latitude: ${currentLocation.latitude}, Longitude: ${currentLocation.longitude}',
        ),
      ),
    );
    setState(() {
      isLoadingMarkers = false;
    });
  }

  Set<Circle> createMyPolygons() {
    final mylocations = ref.watch(locationsProvider);
    Set<Circle> polygons = {};
    for (var location in mylocations) {
      final polygon = Circle(
        radius: location.radius.toDouble(),
        circleId: CircleId(location.name),
        center: LatLng(
          location.coordinates.latitude,
          location.coordinates.longitude,
        ),
        strokeColor: AppColors.accentColor,
        fillColor: AppColors.accentColor.withOpacity(0.2),
        strokeWidth: 2,
      );
      polygons.add(polygon);
    }
    return polygons;
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      createMyMarkers();
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
          (isLoading && isLoadingMarkers)
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  style: isDarkMode(context)? darkStyle: null,
                  initialCameraPosition: CameraPosition(
                  target: Statics.initLocation, // Placeholder position
                  zoom: 2,
                ),
                circles: createMyPolygons(),
                markers: markers,
              ),
    );
  }
}
