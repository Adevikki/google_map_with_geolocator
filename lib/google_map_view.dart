import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
//  late Position device1Location = const LatLng(6.465422, 3.406448);
// late Position device2Location = const LatLng(16.465422, 13.406448);
  late LatLng currentLatLng = const LatLng(6.465422, 3.406448);
  final Completer<GoogleMapController> _controller = Completer();
  // GoogleMapController? mapController;
  // Position? currentPosition;

  @override
  void initState() {
    super.initState();
  }
//   final device1Marker = Marker(
//   markerId: MarkerId("Device 1"),
//   position: LatLng(device1Location.latitude, device1Location.longitude),
//   // icon: BitmapDescriptor.fromAsset("assets/device1_marker.png"),
// );

// final device2Marker = Marker(
//   markerId: MarkerId("Device 2"),
//   position: LatLng(device2Location.latitude, device2Location.longitude),
//   icon: BitmapDescriptor.fromAsset("assets/device2_marker.png"),
// );

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // device1Location = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // device2Location = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentLatLng,
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            _controller.complete(controller);
          });
        },
        markers: <Marker>{
          Marker(
            markerId: const MarkerId("1"),
            position: currentLatLng,
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: const InfoWindow(
              title: "My Location",
            ),
          ),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _getCurrentLocation,
        label: const Text('Home'),
        icon: const Icon(Icons.home),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    await _determinePosition();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLatLng, zoom: 5,)));
  }
}
