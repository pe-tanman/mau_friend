import 'package:emoji_selector/emoji_selector.dart';
import 'package:flutter/material.dart';
import 'package:mau_friend/statics.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:mau_friend/themes/app_color.dart';
import 'package:mau_friend/themes/app_theme.dart';
import 'package:mau_friend/screens/myaccount_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mau_friend/utilities/database_helper.dart';

class AddLocationScreen extends StatefulWidget {
  static const routeName = 'add-location-screen';
  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController iconController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String? autocompletePlace;
  String? address;
  String name = '';
  EmojiData? icon;
  int radius = 0;
  bool isInit = true;
  LatLng coordinates = Statics.initLocation;

  RegisteredLocation? argument;
  var arguments;

  late GoogleMapController mapController;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    iconController.dispose();
    addressController.dispose();
    super.dispose();
  }

  MapLocationPicker _buildMapLocationPicker() {
    return MapLocationPicker(
      apiKey: dotenv.env['Google_Map_API'] ?? '',
      backButton: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back),
      ),
      borderRadius: BorderRadius.all(Radius.circular(500)),
      bottomCardIcon: Icon(Icons.arrow_circle_right_rounded, size: 40),

      popOnNextButtonTaped: true,
      currentLatLng: Statics.initLocation,
      debounceDuration: const Duration(milliseconds: 0),
      onNext: (GeocodingResult? result) {
        if (result != null) {
          setState(() {
            address = result.formattedAddress ?? "";
            convertAddressToLatLng(address!);
          });
        }
      },
      onSuggestionSelected: (PlacesDetailsResponse? result) {
        if (result != null) {
          setState(() {
            autocompletePlace = result.result.formattedAddress ?? "";
          });
        }
      },
    );
  }

  Future<void> convertAddressToLatLng(String address) async {
    var locations = await locationFromAddress(address);
    print('Locations: $locations');
    if (locations.isNotEmpty) {
      setState(() {
        coordinates = LatLng(locations[0].latitude, locations[0].longitude);
        _moveCameraToPosition(coordinates);
      });
      print('Coordinates: ${coordinates.latitude}, ${coordinates.longitude}');
    }
  }

  Future<void> convertLatLngToAdress(LatLng coordinates) async {
    // sometimes  "PlatformException(IO_ERROR" will emerge. It is caused by ratelimit. Hang on a minute.
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
    setState(() {
      this.address = address;
    });
  }

  void _moveCameraToPosition(LatLng position) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments != null) {
        argument = arguments.first;
        convertLatLngToAdress(argument!.coordinates);
        coordinates = argument!.coordinates;
        radius = argument!.radius;
        name = argument!.name;
        icon = EmojiData(
          id: '',
          char: argument!.icon,
          unified: '',
          category: 'Smileys & Emotion',
          name: '',
          skin: 1,
        );
        name = argument!.name;
      }
      isInit = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Location'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.themeColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                icon ??= EmojiData(
                  id: '',
                  char: '📍',
                  unified: '',
                  category: 'Smileys & Emotion',
                  name: '',
                  skin: 1,
                );

                var result = RegisteredLocation(
                  name,
                  icon!.char,
                  coordinates,
                  radius,
                );
                MyLocationDatabaseHelper().insertData(
                  name,
                  icon!.char,
                  coordinates,
                  radius,
                );
                Navigator.pop(context, result);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Add Icon'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                EmojiSelector(
                                  onSelected: (value) {
                                    setState(() {
                                      icon = value;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child:
                        (icon == null)
                            ? Icon(Icons.add_reaction, size: 25)
                            : Text(icon!.char, style: TextStyle(fontSize: 25)),
                  ),
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      initialValue: name,
                      validator:
                          (value) =>
                              (value == null || value.isEmpty)
                                  ? 'Please enter a name'
                                  : null,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        name = value;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              Text('Address', style: appTheme().textTheme.headlineMedium),
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: autocompletePlace ?? address,
                      ),
                      decoration: InputDecoration(border: null),
                      validator:
                          (value) =>
                              (value == null || value.isEmpty)
                                  ? 'Please pick a position'
                                  : null,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return _buildMapLocationPicker();
                          },
                        ),
                      );
                    },
                    icon: Icon(Icons.map),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text('Radius', style: appTheme().textTheme.headlineMedium),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: radius.toString(),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a radius';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Please enter a valid number';
                        }
                        if (int.parse(value) >= 2000) {
                          return 'Limit in 2km';
                        }
                        return null;
                      },
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      onChanged: (value) {
                        setState(() {
                          radius = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('m', style: TextStyle(fontSize: 20)),
                ],
              ),
              SizedBox(height: 30),

              SizedBox(
                height: 300,
                child: GoogleMap(
                  onMapCreated: (controller) => mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: coordinates,
                    zoom: 16,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('selected-location'),
                      position: coordinates,
                    ),
                  },
                  circles: {
                    Circle(
                      circleId: const CircleId('circle_1'),
                      center: coordinates,
                      radius: radius.toDouble(),
                      fillColor: Colors.red.withOpacity(0.5),
                      strokeWidth: 2,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
