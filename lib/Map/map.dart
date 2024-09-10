import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:wellmed/Screens/showprofile.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("Location permission denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      if (_mapController != null && _currentPosition != null) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentPosition!,
              zoom: 14.0,
            ),
          ),
        );
        Provider.of<MapProvider>(context, listen: false)
            .addMarker(_currentPosition!);
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _searchLocation(String query) async {
    try {
      List<geocoding.Location> locations =
          await geocoding.locationFromAddress(query);
      if (locations.isNotEmpty) {
        LatLng newPosition =
            LatLng(locations[0].latitude, locations[0].longitude);

        setState(() {
          _currentPosition = newPosition;
        });

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newPosition,
              zoom: 14.0,
            ),
          ),
        );
        Provider.of<MapProvider>(context, listen: false).addMarker(newPosition);
      } else {
        Fluttertoast.showToast(
          msg: "Location not found",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      print("Error searching location: $e");
      Fluttertoast.showToast(
        msg: "Error searching location: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _confirmLocation() async {
    if (_currentPosition == null) {
      Fluttertoast.showToast(
        msg: "Please select a location first",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Fluttertoast.showToast(
        msg: "User not authenticated",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    String userId = user.uid;

    try {
      // Get the address from the latitude and longitude
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      String locality = placemarks.isNotEmpty
          ? placemarks[0].locality ?? "Locality not found"
          : "Locality not found";
      String address = placemarks.isNotEmpty
          ? "${placemarks[0].name}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}, ${placemarks[0].country}"
          : "Address not found";

      // Save the locality, address, latitude, and longitude to Firebase
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child('Patient Location')
          .child(userId);

      await ref.set({
        'locality': locality, // Storing locality
        'address': address, // Storing full address
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
      });

      Fluttertoast.showToast(
        msg: "Location saved successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      // Navigate to HomeScreen after showing the toast
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CompleteProfileScreen()),
        );
      });
    } catch (error) {
      print("Failed to save location: $error");
      Fluttertoast.showToast(
        msg: "Failed to save location: $error",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MapProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pick Your Location',
          style: TextStyle(
            color: Colors.white, // White text color
            fontFamily: 'Nunito', // Nunito font
            fontSize: 20, // Font size 18
            fontWeight: FontWeight
                .bold, // Optional: You can adjust the weight if needed
          ),
        ),
        backgroundColor: Color(0xFF0000FF), // Blue background color
        iconTheme: IconThemeData(
          color: Colors.white, // White color for back arrow
        ),
      ),
      body: Stack(
        children: [
          _currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 14,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      if (_currentPosition != null) {
                        provider.addMarker(_currentPosition!);
                      }
                    },
                    markers: provider.markers,
                    myLocationEnabled: true,
                    onTap: (LatLng latLng) {
                      setState(() {
                        _currentPosition = latLng;
                      });
                      provider.addMarker(latLng);
                    },
                  ),
                ),
          Positioned(
            top: 15,
            right: 15,
            left: 15,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1.5,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
                color: Colors.white,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search location',
                  prefixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      // Trigger search when search icon is pressed
                      if (_searchController.text.isNotEmpty) {
                        _searchLocation(_searchController.text);
                      } else {
                        Fluttertoast.showToast(
                          msg: "Please enter a location to search",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                      }
                    },
                  ), // Search icon on the left
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            // Clear text when clear icon is pressed
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null, // Clear icon on the right
                  fillColor: Colors.transparent,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 15.0, 15.0),
                ),
                onChanged: (value) {
                  setState(() {});
                },
                onSubmitted: (value) {
                  // Trigger search when user presses enter
                  if (value.isNotEmpty) {
                    _searchLocation(value);
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 30, // Increased from 10 to 30 to move it up
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _confirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0000FF), // Blue background color
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Reduced radius to 8
                ),
              ),
              child: const Text(
                'Confirm Location',
                style: TextStyle(
                  color: Colors.white, // White text color
                  fontFamily: 'Nunito', // Nunito font
                  fontSize: 16, // Font size 16
                  fontWeight: FontWeight
                      .bold, // Optional: You can adjust the weight if needed
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapProvider extends ChangeNotifier {
  final Set<Marker> _markers = {};

  Set<Marker> get markers => _markers;

  void addMarker(LatLng position) {
    _markers
        .clear(); // Clear previous markers if you want only one marker at a time
    _markers.add(
      Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        draggable: true, // Make the marker draggable
        onDragEnd: (newPosition) {
          // Update the position after the marker is dragged
          _markers.clear();
          _markers.add(
            Marker(
              markerId: MarkerId(newPosition.toString()),
              position: newPosition,
              draggable: true,
            ),
          );
          notifyListeners();
        },
      ),
    );
    notifyListeners();
  }
}
