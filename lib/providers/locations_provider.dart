import 'package:map_location_picker/map_location_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/utilities/database_helper.dart';

class RegisteredLocation {
  final String name;
  final String icon;
  final LatLng coordinates;
  final int radius;
  final String? address;
  RegisteredLocation({
    required this.name,
    required this.icon,
    required this.coordinates,
    required this.radius,
    this.address,
  });
}

@riverpod
class LocationsProvider extends Notifier<List<RegisteredLocation>> {
  @override
  List<RegisteredLocation> build() => [];

  //riverpod
  Future<void> updateLocations(List<RegisteredLocation> locations) async {
    //save to riverpod
    state = locations;
  }

  Future<void> loadLocations() async {
    MyLocationDatabaseHelper dbHelper = MyLocationDatabaseHelper();

    var result = await dbHelper.getAllData();
    var output = <RegisteredLocation>[];
    if (result != null && result.isNotEmpty) {
      result.forEach((element) {
        var coordinates = LatLng(element['latitude'], element['longitude']);
        var name = element['name'];
        var icon = element['icon'];
        var radius = element['radius'];

        output.add(
          RegisteredLocation(
            name: name,
            icon: icon,
            coordinates: coordinates,
            radius: radius,
          ),
        );
      });
      state = output;
    } else {
      state = [];
    }
  }
}

final locationsProvider =
    NotifierProvider<LocationsProvider, List<RegisteredLocation>>(
      LocationsProvider.new,
    );
