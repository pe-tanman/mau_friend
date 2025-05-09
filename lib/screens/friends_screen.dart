import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  LocationData? _currentLocation;
  final location = Location();
  List locationList = [];
  String userState = 'offline';

  @override
  void initState() {
    super.initState();
    initLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
        locationList.add(_currentLocation);
        verocity();
      });
    });
  }

  void verocity() {
    double verocity = 0;
    double distance = locationList[locationList.length - 1].distanceTo(
      locationList[locationList.length - 2],
    );
    verocity = distance;

    if (verocity > 5) {
      userState = '電車移動中🚞';
    } else if (verocity > 1) {
      userState = '徒歩移動中🦶';
    } else {
      userState = '停止中🛑';
    }
  }

  Future<void> initLocation() async {
    bool? _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (_serviceEnabled == null || _serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await location.getLocation();
  }

  Future<void> getLocation() async {
    _currentLocation = await location.getLocation();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 100),
              const CircleAvatar(radius: 50),
              const SizedBox(height: 50),
              Text(userState),
              const SizedBox(height: 50),
              Text(
                "location: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}",
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => locationPicker(),
                  );
                },
                child: const Text('Add location'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }

  Widget locationPicker() {
    final TextEditingController placeNameController = TextEditingController();
    final TextEditingController latitudeController = TextEditingController();
    final TextEditingController longitudeController = TextEditingController();
    return AlertDialog(
      title: const Text('Enter Location Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: placeNameController,
            decoration: const InputDecoration(labelText: 'Place Name'),
          ),
          TextField(
            controller: latitudeController,
            decoration: const InputDecoration(labelText: 'Latitude'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: longitudeController,
            decoration: const InputDecoration(labelText: 'Longitude'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Handle the form submission here
            String placeName = placeNameController.text;
            double? latitude = double.tryParse(latitudeController.text);
            double? longitude = double.tryParse(longitudeController.text);

            if (latitude != null && longitude != null) {
              // Do something with the location data
              print(
                'Place Name: $placeName, Latitude: $latitude, Longitude: $longitude',
              );
            }

            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget locationIndicator() {
    location.onLocationChanged.listen((LocationData currentLocation) {});
    return Card(
      child: Column(
        children: [
          const CircleAvatar(radius: 50),
          const SizedBox(height: 50),
          const Text("移動中🚃"),
          const SizedBox(height: 50),
          Text(
            "location: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}",
          ),
          Text(
            '緯度: ${_currentLocation?.latitude}, 経度: ${_currentLocation?.longitude}',
          ),
        ],
      ),
    );
  }
}