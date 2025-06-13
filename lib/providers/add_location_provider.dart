import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mau_friend/providers/locations_provider.dart';

class AddLocationProvider extends StateNotifier<RegisteredLocation> {
  AddLocationProvider()
    : super(
        RegisteredLocation(
          name: '',
          icon: '',
          coordinates: LatLng(0, 0),
          radius: 0,
        ),
      );

  void updateLocation(RegisteredLocation location) {
    state = location;
  }

 
}
final addLocationProvider =
    StateNotifierProvider<AddLocationProvider, RegisteredLocation>((ref) {
      return AddLocationProvider();
    });
