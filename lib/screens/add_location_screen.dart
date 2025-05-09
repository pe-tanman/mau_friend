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

  @override
  void dispose() {
    nameController.dispose();
    iconController.dispose();
    addressController.dispose();
    super.dispose();
  }

  MapLocationPicker _buildMapLocationPicker() {
    return MapLocationPicker(
      backButton: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back),
      ),
      borderRadius: BorderRadius.all(Radius.circular(500)),
      bottomCardIcon: Icon(Icons.arrow_circle_right_rounded, size: 40),
      apiKey: 'AIzaSyCjW1ujz7fEpUKNuRo_anFBWt5xtgEmVk4',
      popOnNextButtonTaped: true,
      currentLatLng: Statics.initLocation,
      debounceDuration: const Duration(milliseconds: 0),
      onNext: (GeocodingResult? result) {
        if (result != null) {
          setState(() {
            address = result.formattedAddress ?? "";
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

  void convertAddressToLatLng(String address) async {
    var locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      setState(() {
        coordinates = LatLng(locations[0].latitude, locations[0].longitude);
      });
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
              icon ??= EmojiData(
                id: '',
                char: '📍',
                unified: '',
                category: 'Smileys & Emotion',
                name: '',
                skin: 1,
              );

              var result = RegisteredLocation(name, icon!.char, coordinates, radius);
              Navigator.pop(context, result);
              //save on db here
            },
            child: Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: Key('add_location_form'),
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
                      validator: (value) => (value == null || value.isEmpty)
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
                      controller: TextEditingController(text: autocompletePlace ?? address),
                      decoration: InputDecoration(
                      border: null,
                      ),
                      validator: (value) => (value == null || value.isEmpty)
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
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      onChanged: (value) {
                        radius = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('m', style: TextStyle(fontSize: 20)),
                ],
              ),
              SizedBox(height: 40),
                SizedBox(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                  target: coordinates,
                  zoom: 14,
                  ),
                  markers: {
                  Marker(
                    markerId: MarkerId('selected-location'),
                    position: coordinates,
                  ),
                  },
                  onTap: (LatLng position) {
                  setState(() {
                    coordinates = position;
                  });
                  },
                   circles: {
                    Circle(
                      circleId: const CircleId('circle_1'),
                      center: const LatLng(
                        35.68123428932672,
                        139.76714355230686,
                      ),
                      radius: 500,
                      fillColor: Colors.red.withOpacity(0.5),
                      strokeWidth: 5,
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
