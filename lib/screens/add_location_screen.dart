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
  String address = "";
  String name = '';
  EmojiData? icon;
  int radius = 0;
  LatLng coordinates = Statics.initLocation;

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
      apiKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '',
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
            convertAddressToLatLng(address);
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
      });
      print('Coordinates: ${coordinates.latitude}, ${coordinates.longitude}');
    }
  }

  @override
  Widget build(BuildContext context) {
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

                Navigator.pop(context, result);
                //save on db here}
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
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a radius';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Please enter a valid number';
                        }
                        if (int.parse(value) >= 200) {
                          return 'Limit in 200m';
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
                  initialCameraPosition: CameraPosition(
                    target: coordinates,
                    zoom: 50,
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
