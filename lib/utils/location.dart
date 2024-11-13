// ignore_for_file: deprecated_member_use

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MyLocation {
  String? currentAddress;
  Position? currentPosition;
  Future<void> getAddressFromLatLon(Position position) async {
    await placemarkFromCoordinates(
            currentPosition!.latitude, currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      currentAddress = '${place.locality}, ${place.country}';
      return currentAddress;
    });
  }

  // ignore: unused_element
  Future<void> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      currentPosition = position;
      getAddressFromLatLon(currentPosition!);
    });
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    // ignore: unused_local_variable
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled;
  }
}
