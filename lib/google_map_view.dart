import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_with_geolocator/constant.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
//  late Position device1Location = const LatLng(6.465422, 3.406448);
// late Position device2Location = const LatLng(16.465422, 13.406448);
  late LatLng currentLatLng = LatLng(37.33500926, -122.03272188);
  late LatLng destinationLatLng = LatLng(37.33429383, -122.06600055);
  bool isInitialized = false;
  bool isPermission = false;
  final Completer<GoogleMapController> _controller = Completer();
  // GoogleMapController? mapController;
  // Position? currentPosition;

  @override
  void initState() {
    _getCurrentLocation();
    getPolyPoints();
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
    setState(() {
      isPermission = true;
    });
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // device1Location = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // device2Location = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      // currentLatLng = LatLng(position.latitude, position.longitude);
      currentLatLng = LatLng(position.latitude, position.longitude);
      isInitialized = true;
    });
  }

  List<LatLng> polylineCoodinates = [];

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(currentLatLng.latitude, currentLatLng.longitude),
      PointLatLng(destinationLatLng.latitude, destinationLatLng.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoodinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      if (isPermission) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      return const Scaffold(
        body: Center(
          child: Text('You need location permission to view this page'),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLatLng,
              zoom: 13.5,
            ),
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _controller.complete(controller);
              });
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId("route"),
                points: polylineCoodinates,
              ),
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
              Marker(
                markerId: const MarkerId("2"),
                position: destinationLatLng,
                icon: BitmapDescriptor.defaultMarker,
                infoWindow: const InfoWindow(
                  title: "Destination",
                ),
              ),
            },
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _getCurrentLocation,
      //   label: const Text('Home'),
      //   icon: const Icon(Icons.home),
      // ),
    );
  }

  Future<void> _getCurrentLocation() async {
    await _determinePosition();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: currentLatLng,
      zoom: 5,
    )));
  }
}
