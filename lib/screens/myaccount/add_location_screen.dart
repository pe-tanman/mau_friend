import 'dart:ffi';
import 'dart:ui' as ui;

import 'package:emoji_selector/emoji_selector.dart';
import 'package:flutter/material.dart';
import 'package:mau_friend/providers/my_status_provider.dart';
import 'package:mau_friend/utilities/statics.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:mau_friend/themes/app_color.dart';
import 'package:mau_friend/themes/app_theme.dart';
import 'package:mau_friend/screens/myaccount/myaccount_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mau_friend/utilities/database_helper.dart';
import 'package:mau_friend/providers/locations_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

class AddLocationScreen extends ConsumerStatefulWidget {
  static const routeName = 'add-location-screen';
  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends ConsumerState<AddLocationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController iconController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String? autocompletePlace;
  String? address;
  String name = '';
  EmojiData? icon;
  int radius = 100;
  bool isInit = true;
  LatLng coordinates = Statics.initLocation;
  Set<Marker> markers = {};
  bool isLoadingMarkers = true;
  double _sliderValue = log(100);

  RegisteredLocation? argument;
  var arguments;

  late GoogleMapController mapController;

  final _formKey = GlobalKey<FormState>();

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

  @override
  void dispose() {
    nameController.dispose();
    iconController.dispose();
    addressController.dispose();
    super.dispose();
  }

  MapLocationPicker _buildMapLocationPicker() {
    return MapLocationPicker(
      mapStyle: (isDarkMode(context) ? darkStyle : null),
      apiKey: dotenv.env['Google_Map_API'] ?? '',

      backButton: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back),
      ),
      searchHintText: '',

      borderRadius: BorderRadius.all(Radius.circular(500)),
      bottomCardIcon: Icon(Icons.arrow_circle_right_rounded, size: 40),

      popOnNextButtonTaped: true,
      currentLatLng: coordinates,
      debounceDuration: const Duration(milliseconds: 0),
      onNext: (GeocodingResult? result) {
        if (result != null) {
          setState(() {
            coordinates = LatLng(
              result.geometry.location.lat,
              result.geometry.location.lng,
            );
            _moveCameraToPosition(coordinates);
            createMyMarkers();
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

  Future<void> updateStatus() async {
    final currentPosition = await MyStatusProvider().getCurrentPosition();
    final myLocations = ref.read(locationsProvider);
    ref.read(myStatusProvider.notifier).updateMyStatus(currentPosition, myLocations);
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

  void deleteLocaition() {
    MyLocationDatabaseHelper().deleteData(name);
    var result = RegisteredLocation('delete', icon!.char, coordinates, radius);
    Navigator.pop(context, result);
  }

  void saveLocation() {
    icon ??= EmojiData(
      id: '',
      char: '📍',
      unified: '',
      category: 'Smileys & Emotion',
      name: '',
      skin: 1,
    );

    if (argument != null && argument!.name != name) {
      MyLocationDatabaseHelper().deleteData(argument!.name);
    }

    var result = RegisteredLocation(name, icon!.char, coordinates, radius);
    MyLocationDatabaseHelper().insertData(
      name,
      icon!.char,
      coordinates,
      radius,
    );

    Navigator.pop(context, result);
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
    final double size =
        (textPainter.width > textPainter.height
            ? textPainter.width
            : textPainter.height) +
        padding * 2;

    // Add a white circle background
    final paint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    // Add an outline around the circle
    final outlinePaint =
        Paint()
          ..color = AppColors.themeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.0;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, outlinePaint);

    // Draw the emoji on top of the circle
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  double radiusToZoom() {
    double zoom =
        24.593 *
        pow(radius, -0.085); //this function is just based on instinciton
    return zoom;
  }

  Future<void> createMyMarkers() async {
    final mylocations = ref.watch(locationsProvider);
    markers = {};
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
        icon: await createEmojiMarker(icon?.char ?? '📍'),
        markerId: const MarkerId('selected-location'),
        position: coordinates,
        infoWindow: InfoWindow(
          title: 'Current Location',
          snippet:
              'Latitude: ${coordinates.latitude}, Longitude: ${coordinates.longitude}',
        ),
      ),
    );
    setState(() {
      isLoadingMarkers = false;
    });
  }

  Set<Circle> createMyPolygons() {
    final mylocations = ref.watch(locationsProvider);
    ;
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
    polygons.add(
      Circle(
        radius: radius.toDouble(),
        circleId: const CircleId('selected-location'),
        center: coordinates,
        strokeColor: Colors.red,
        fillColor: Colors.red.withOpacity(0.2),
        strokeWidth: 2,
      ),
    );
    return polygons;
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      createMyMarkers();
      arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments != null) {
        argument = arguments.first;
        convertLatLngToAdress(argument!.coordinates);
        coordinates = argument!.coordinates;
        radius = argument!.radius;
        _sliderValue = log(radius);
        print("init e^slider${pow(e, _sliderValue)}");
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
          IconButton(
            onPressed: () {
              deleteLocaition();
            },
            icon: Icon(Icons.delete_outlined),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  saveLocation();
                }
              },
              child: Text('Save'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                              content: SingleChildScrollView(
                                child: EmojiSelector(
                                  onSelected: (value) {
                                    createMyMarkers();
                                    setState(() {
                                      icon = value;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child:
                          (icon == null)
                              ? Icon(Icons.add_reaction, size: 25)
                              : Text(
                                icon!.char,
                                style: TextStyle(fontSize: 25),
                              ),
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
                          createMyMarkers();
                          name = value;
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                Text(
                  'Address',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
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
                Text(
                  'Radius',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 10),

                //to set radius more precisely, we use radius = exp(_sliderValue)
                SizedBox(
                  width: 100,
                  child: Slider(
                    inactiveColor: AppColors.backgroundColor,
                    value: _sliderValue,
                    min: log(5),
                    max: log(2000),
                    divisions: 1999,
                    label: '$radius m',
                    onChanged: (value) {
                      createMyMarkers();
                      setState(() {
                        print("result e^slider${pow(e, _sliderValue)}");
                        _sliderValue = value;
                        radius = pow(e, value).round();
                      });
                    },
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  height: 300,
                  child:
                      isLoadingMarkers
                          ? Center(child: CircularProgressIndicator())
                          : GoogleMap(
                            style: isDarkMode(context) ? darkStyle : null,
                            onMapCreated:
                                (controller) => mapController = controller,
                            initialCameraPosition: CameraPosition(
                              target: coordinates,
                              zoom: isInit ? 8 : radiusToZoom(),
                            ),
                            markers: markers,
                            circles: createMyPolygons(),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
