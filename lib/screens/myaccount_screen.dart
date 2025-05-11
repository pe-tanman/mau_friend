import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/screens/setting_screen.dart';
import 'package:mau_friend/statics.dart';
import 'package:geocoding/geocoding.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:mau_friend/themes/app_theme.dart';
import 'package:mau_friend/screens/add_location_screen.dart';
import 'package:mau_friend/utilities/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 

class RegisteredLocation {
  final String name;
  final String icon;
  final LatLng coordinates;
  final int radius;
  RegisteredLocation(this.name, this.icon, this.coordinates, this.radius);
}

class MyAccountScreen extends ConsumerStatefulWidget {
  @override
  static const routeName = 'my-account-screen';
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends ConsumerState<MyAccountScreen> {
  late GoogleMapController mapController;
  List<RegisteredLocation> registeredLocations = [];
  String address = "";
  String autocompletePlace = "";
  LatLng coordinates = Statics.initLocation;
  bool isLoading = true;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    // Load initial data
    loadRegisteredLocations();
  }

  Future<String> convertLatLngToAdress(LatLng coordinates) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      coordinates.latitude,
      coordinates.longitude,
    );
    String address = '';
    if (placemarks.isNotEmpty) {
      // Concatenate non-null components of the address
      var streets = placemarks.reversed
          .map((placemark) => placemark.street)
          .where((street) => street != null);

      // Filter out unwanted parts
      streets = streets.where(
        (street) =>
            street!.toLowerCase() !=
            placemarks.reversed.last.locality!.toLowerCase(),
      ); // Remove city names
      streets = streets.where(
        (street) => !street!.contains('+'),
      ); // Remove street codes

      address += streets.join(', ');

      address += ', ${placemarks.reversed.last.subLocality ?? ''}';
      address += ', ${placemarks.reversed.last.locality ?? ''}';
      address += ', ${placemarks.reversed.last.subAdministrativeArea ?? ''}';
      address += ', ${placemarks.reversed.last.administrativeArea ?? ''}';
      address += ', ${placemarks.reversed.last.postalCode ?? ''}';
      address += ', ${placemarks.reversed.last.country ?? ''}';
    }
    return address;
  }

  Future<void> loadRegisteredLocations() async {
    // Simulate loading data from a database or API
    final myLocationsMap = await MyLocationDatabaseHelper().getAllData();

    registeredLocations =
        myLocationsMap.map((location) {
          return RegisteredLocation(
            location['name'],
            location['icon'],
            LatLng(location['latitude'], location['longitude']),
            location['radius'],
          );
        }).toList();

    setState(() {
      isLoading = false;
    });
  }

  Widget _buildListCard(int index) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          radius: 30,
          child: Text(
            registeredLocations[index].icon,
            style: TextStyle(fontSize: 25),
          ),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
        title: Text(
          registeredLocations[index].name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.pushNamed(
            context,
            AddLocationScreen.routeName,
            arguments: {registeredLocations[index]},
          ).then((value) {
            if (value != null) {
              var location = value as RegisteredLocation;
              if (location.name == 'delete') {
                setState(() {
                  registeredLocations.removeAt(index);
                });
              } else {
                setState(() {
                  registeredLocations[index] = location;
                });
              }
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, SettingScreen.routeName);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(radius: 50, backgroundImage: NetworkImage(profile['iconLink']??'https://images.pexels.com/photos/2071882/pexels-photo-2071882.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500))',)),// a cat image
            SizedBox(height: 10),
            Text(
              profile['username'] ?? 'Username',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              profile['bio'] ?? 'Bio',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),

            SizedBox(height: 20),
            Divider(),

            if (!isLoading)
              ListView.builder(
                itemBuilder: (context, index) {
                  return _buildListCard(index);
                },
                itemCount: registeredLocations.length,
                shrinkWrap: true,
              ),
            TextButton.icon(
              label: Text('Add Location'),
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, AddLocationScreen.routeName).then((
                  value,
                ) {
                  if (value != null) {
                    setState(() {
                      registeredLocations.add(value as RegisteredLocation);
                    });
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
