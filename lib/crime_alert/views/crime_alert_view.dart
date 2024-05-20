import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:secure_alert/utils/bottom_navigation.dart';
import 'package:secure_alert/utils/custom_widgets.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';

import '../models/alert_model.dart';

class CrimeAlertView extends StatefulWidget {
  const CrimeAlertView({super.key});

  @override
  State<CrimeAlertView> createState() => _CrimeAlertViewState();
}

const kGoogleApiKey = '<GoogleMapAPIKey>';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _CrimeAlertViewState extends State<CrimeAlertView> {
  CameraPosition? initialCameraPosition;

  Set<Marker> markersList = {};
  List<Alert> alerts = [];

  double lng = 19.1335;
  double lat = 72.8541;
  late GoogleMapController googleMapController;

  final Mode _mode = Mode.overlay;

  getCurrentLocation() async {
    final position = await _determinePosition();
    setState(() {
      lng = position.longitude;
      lat = position.latitude;

      markersList.add(Marker(
          markerId: const MarkerId("0"),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet)));
    });

    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 14.0)));
    getCrimeAlerts();
  }

  Future getAlertList() async {
    final reportRef = FirebaseDatabase.instance.ref().child('reports');

    reportRef.onValue.listen((event) async {
      for (final child in event.snapshot.children) {
        final alertID = await json.decode(json.encode(child.key));
        Map data = await json.decode(json.encode(child.value));

        double distanceInMeters = await
        Geolocator.distanceBetween(
            lat, lng,
            double.parse(data['latitude']), double.parse(data['longitude']));

        var lt = double.parse(data['latitude']);
        var ln = double.parse(data['longitude']);

        markersList.add(Marker(
            markerId: MarkerId(alertID),
            position: LatLng(lt, ln),
            infoWindow:
                InfoWindow(title: data["type"], snippet: data["date"])));
      }
      setState(() {});
    }, onError: (error) {
      // ignore: avoid_print
      print('Error gettinng post list');
    });
  }

  getCrimeAlerts() async {
    await getAlertList();
    setState(() {});
  }

  @override
  void initState() {
    initialCameraPosition =
        CameraPosition(target: LatLng(lng, lat), zoom: 16.0);
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: "Crime Alerts"),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: initialCameraPosition!,
            markers: markersList.map((e) => e).toSet(),
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
            },
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
                onPressed: _handlePressButton,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(10))),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.red.shade900,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Enter Area, city or State",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    )
                  ],
                )),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 10.0, left: 10, right: 100),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.deepPurple.shade400,
                    ),
                    const Text(
                      "Current Location",
                      style: TextStyle(fontSize: 12),
                    ),
                    const Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    const Text(
                      "Crime locators",
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar:
          const CustomBottomNavigationBar(defaultSelectedIndex: 0),
    );
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(
          msg: "Please enable the location to use this feature");
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: _mode,
        language: 'en',
        strictbounds: false,
        types: [""],
        logo: Container(
          height: 1,
        ),
        decoration: InputDecoration(
            hintText: 'Enter Area, city or State',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white))),
        components: [
          
          Component(Component.country, "usa"),
          Component(Component.country, "in")
        ]);

    displayPrediction(p!, homeScaffoldKey.currentState);
  }

  void onError(PlacesAutocompleteResponse response) {}

  Future<void> displayPrediction(
      Prediction p, ScaffoldState? currentState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    lat = detail.result.geometry!.location.lat;
    lng = detail.result.geometry!.location.lng;

    //add marker for the selected place
    markersList.add(Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(title: detail.result.name)));

    //set camera to the place selected
    setState(() async {
      getCrimeAlerts();
      googleMapController
          .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
    });
  }
}
