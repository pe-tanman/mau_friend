import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mau_friend/providers/my_status_provider.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/screens/settings/setting_screen.dart';
import 'package:mau_friend/themes/app_color.dart';
import 'package:mau_friend/utilities/statics.dart';
import 'package:geocoding/geocoding.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:mau_friend/themes/app_theme.dart';
import 'package:mau_friend/screens/myaccount/add_location_screen.dart';
import 'package:mau_friend/utilities/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/screens/settings/profile_setting_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mau_friend/utilities/location_helper.dart';
import 'dart:async';
import 'package:mau_friend/providers/locations_provider.dart';

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
    loadRegisteredLocations();
    super.initState();
    ref.read(profileProvider.notifier).loadMyProfile();

    LocationHelper()
        .initLocationSetting()
        .then((_) {
          LocationHelper().trackLocation(ref);
        })
        .catchError((error) {
          print('Error initializing location settings: $error');
        });
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
      color: Theme.of(context).colorScheme.surface,
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
              ref
                  .read(locationsProvider.notifier)
                  .updateLocations(registeredLocations);
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
            Card(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
              child: Column(
                children: [
                  SizedBox(height: 30),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      (profile.iconLink != null && profile.iconLink != '')
                          ? profile.iconLink!
                          : Statics.defaultIconLink,
                    ),
                  ), // a cat image
                  SizedBox(height: 10),
                  Text(
                    profile.name ?? 'Username',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    profile.bio ?? 'Bio',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                  if (profile.name == null)
                    TextButton.icon(
                      label: Text('Complete your profile'),
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          ProfileSettingScreen.routeName,
                        );
                      },
                    ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ref.watch(myStatusProvider).icon,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          ref.watch(myStatusProvider).status,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),

            //Tofo:add cute and informative icons
            //location list
            SizedBox(height: 20),

            if (!isLoading)
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return _buildListCard(index);
                },
                itemCount: registeredLocations.length,
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
                      ref
                          .read(locationsProvider.notifier)
                          .updateLocations(registeredLocations);
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
