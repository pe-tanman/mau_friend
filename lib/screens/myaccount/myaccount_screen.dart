import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mau_friend/providers/emergency_provider.dart';
import 'package:mau_friend/providers/my_status_provider.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/screens/myaccount/emergency_screen.dart';
import 'package:mau_friend/screens/settings/setting_screen.dart';
import 'package:mau_friend/utilities/statics.dart';
import 'package:geocoding/geocoding.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:mau_friend/screens/myaccount/add_location_screen.dart';
import 'package:mau_friend/utilities/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/screens/settings/profile_setting_screen.dart';

import 'dart:async';
import 'package:mau_friend/providers/locations_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';

class MyAccountScreen extends ConsumerStatefulWidget {
  static const routeName = 'my-account-screen';
  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends ConsumerState<MyAccountScreen> {
  late GoogleMapController mapController;
  List<RegisteredLocation> registeredLocations = [];
  String address = "";
  String autocompletePlace = "";
  LatLng coordinates = Statics.initLocation;
  bool isLoading = true;
  bool isInit = true;

  @override
  void initState() {
    loadRegisteredLocations();
    super.initState();
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
    print('Loading registered locations...');
    // Simulate loading data from a database or API
    final myLocationsMap = await MyLocationDatabaseHelper().getAllData();
    if (myLocationsMap == null || myLocationsMap.isEmpty) {
      registeredLocations = [];
      setState(() {
        isLoading = false;
      });
      return;
    }
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

  Widget _buildMyCard(Profile profile) {
    int tappedCount = 5;
    return Card(
      color:
          (ref.watch(emergencyProvider.notifier).isEmergencyActive())
              ? Colors.red
              : Theme.of(context).cardColor,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 3,
      child: InkWell(
        onTap: () {
          tappedCount--;
          if (tappedCount > 0) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.redAccent,

                content: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(Icons.emergency),
                      ),
                      Text(
                        'Tap $tappedCount more times, turn on Feeling Unsafe',
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            Navigator.pushNamed(context, EmergencyScreen.routeName);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
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
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 160, minWidth: 50),
                      child: Text(
                        ref.watch(myStatusProvider).status,
                        style: Theme.of(context).textTheme.labelMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> callLocationDataAnalysis() async {
    //sample data
    final behaviorData = """[
      {"t": "2025-06-10 07:00:00", "x": 35.7020, "y": 139.7750},
  {"t": "2025-06-10 07:05:00", "x": 35.7021, "y": 139.7751},
  {"t": "2025-06-10 07:10:00", "x": 35.7020, "y": 139.7752},
  {"t": "2025-06-10 07:15:00", "x": 35.7022, "y": 139.7750},
  {"t": "2025-06-10 07:20:00", "x": 35.7021, "y": 139.7751},
  {"t": "2025-06-10 07:25:00", "x": 35.7020, "y": 139.7750},
  {"t": "2025-06-10 07:30:00", "x": 35.7019, "y": 139.7749},
  {"t": "2025-06-10 07:35:00", "x": 35.7018, "y": 139.7748},
  {"t": "2025-06-10 07:40:00", "x": 35.7015, "y": 139.7745},
  {"t": "2025-06-10 07:45:00", "x": 35.7010, "y": 139.7740},
  {"t": "2025-06-10 07:50:00", "x": 35.7005, "y": 139.7735},
  {"t": "2025-06-10 07:55:00", "x": 35.6990, "y": 139.7720},
  {"t": "2025-06-10 08:00:00", "x": 35.6985, "y": 139.7715},
  {"t": "2025-06-10 08:05:00", "x": 35.6980, "y": 139.7710},
  {"t": "2025-06-10 08:10:00", "x": 35.6950, "y": 139.7680},
  {"t": "2025-06-10 08:15:00", "x": 35.6920, "y": 139.7650},
  {"t": "2025-06-10 08:20:00", "x": 35.6890, "y": 139.7620},
  {"t": "2025-06-10 08:25:00", "x": 35.6860, "y": 139.7590},
  {"t": "2025-06-10 08:30:00", "x": 35.6830, "y": 139.7560},
  {"t": "2025-06-10 08:35:00", "x": 35.6810, "y": 139.7530},
  {"t": "2025-06-10 08:40:00", "x": 35.6811, "y": 139.7531},
  {"t": "2025-06-10 08:45:00", "x": 35.6810, "y": 139.7532},
  {"t": "2025-06-10 08:50:00", "x": 35.6812, "y": 139.7530},
  {"t": "2025-06-10 08:55:00", "x": 35.6811, "y": 139.7531},
  {"t": "2025-06-10 09:00:00", "x": 35.6810, "y": 139.7530},
  {"t": "2025-06-10 09:05:00", "x": 35.6811, "y": 139.7531},
  {"t": "2025-06-10 09:10:00", "x": 35.6810, "y": 139.7532},
  {"t": "2025-06-10 09:15:00", "x": 35.6812, "y": 139.7530},
  {"t": "2025-06-10 09:20:00", "x": 35.6811, "y": 139.7531},
  {"t": "2025-06-10 09:25:00", "x": 35.6810, "y": 139.7530},
  {"t": "2025-06-10 09:30:00", "x": 35.6811, "y": 139.7531},
  {"t": "2025-06-10 09:35:00", "x": 35.6810, "y": 139.7532},
  {"t": "2025-06-10 09:40:00", "x": 35.6812, "y": 139.7530},
  {"t": "2025-06-10 09:45:00", "x": 35.6811, "y": 139.7531},
  {"t": "2025-06-10 09:50:00", "x": 35.6810, "y": 139.7530},
  {"t": "2025-06-10 09:55:00", "x": 35.6811, "y": 139.7531},
  {"t": "2025-06-10 10:00:00", "x": 35.6810, "y": 139.7532},
  {"t": "2025-06-10 10:05:00", "x": 35.6812, "y": 139.7530},
  {"t": "2025-06-10 10:10:00", "x": 35.6811, "y": 139.7531},
  {"t": "2025-06-10 10:15:00", "x": 35.6810, "y": 139.7530},
  {"t": "2025-06-10 10:20:00", "x": 35.6811, "y": 139.7531},
  {"t": "2025-06-10 10:25:00", "x": 35.6810, "y": 139.7532},
  {"t": "2025-06-10 10:30:00", "x": 35.6812, "y": 139.7530},
  {"t": "2025-06-10 10:35:00", "x": 35.6811, "y": 139.7531},
  {"t": "2025-06-10 10:40:00", "x": 35.6810, "y": 139.7530},
  {"t": "2025-06-10 10:45:00", "x": 35.6811, "y": 139.7531},
  {"t": "2025-06-10 10:50:00", "x": 35.6810, "y": 139.7532},
  {"t": "2025-06-10 10:55:00", "x": 35.6812, "y": 139.7530},
  {"t": "2025-06-10 11:00:00", "x": 35.6811, "y": 139.7531},
  {"t": "2025-06-10 11:05:00", "x": 35.6810, "y": 139.7530},
  {"t": "2025-06-10 11:10:00", "x": 35.6811, "y": 139.7531},
  {"t": "2025-06-10 11:15:00", "x": 35.6810, "y": 139.7532},
  {"t": "2025-06-10 11:20:00", "x": 35.6812, "y": 139.7530},
  {"t": "2025-06-10 11:25:00", "x": 35.6811, "y": 139.7531},
  {"t": "2025-06-10 11:30:00", "x": 35.6810, "y": 139.7530}
    ]""";
    final callable = FirebaseFunctions.instance.httpsCallable(
      'analyze_behavior',
    );
    try {
      final result = await callable.call(behaviorData);
      print("Result: ${result.data}");
    } catch (e) {
      print("Error calling function: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    if (isInit) {
      ref.read(profileProvider.notifier).loadMyProfile();
      ref.read(locationsProvider.notifier).loadLocations();
      loadRegisteredLocations();
      final statusNotifier = ref.read(myStatusProvider.notifier);
      statusNotifier.initLocationSetting();

      statusNotifier.getCurrentPosition().then((position) {
        statusNotifier.updateMyStatus(position, registeredLocations);
      });
      isInit = false;

      statusNotifier.startTrackingLocation();
      MyLocationDatabaseHelper().initMyLocationDatabase();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account'),
        automaticallyImplyLeading: false,
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
            _buildMyCard(profile),
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
            SizedBox(height: 20),
            TextButton.icon(
              label: Text('Favorite Place Recommendation'),
              icon: Icon(Icons.bolt),
              onPressed: () {
                callLocationDataAnalysis();
              },
            ),
          ],
        ),
      ),
    );
  }
}
