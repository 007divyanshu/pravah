import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

class LocationPage extends StatefulWidget {
  static const String routeName = 'SelectVenue_page';
  const LocationPage({Key? key}) : super(key: key);
  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final _locationController = TextEditingController();
  var uuid = const Uuid();
  String? _sessionToken;
  List<dynamic> _placeList = [];
  Completer<GoogleMapController> mapController = Completer();
  static const CameraPosition _kGoogle = CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 14.4746,
  );
  final Set<Marker> _markers = <Marker>{};
  LatLng? coordinates;
  String? selectedLocationName; // Store the selected location name

  // Theme colors from SuggestionsPage
  final Color _backgroundColor = const Color(0xFF0B2732); // Dark blue background
  final Color _cardColor = const Color(0xFFF5F5DC); // Cream color for cards
  final Color _accentColor = const Color(0xFF61A6AB); // Teal accent color
  final Color _textColor = Colors.white;
  final Color _darkTextColor = const Color(0xFF0B2732); // Dark text for light backgrounds

  @override
  void initState() {
    super.initState();
    _locationController.addListener(_onChanged);
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_locationController.text.isEmpty) {
      setState(() {
        _placeList = [];
      });
      return;
    }
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_locationController.text);
  }

  Future<void> getSuggestion(String input) async {
    String PLACES_API_KEY =dotenv.env['GOOGLE_MAP_API_KEY'] ?? ''; // Replace with actual API key
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$PLACES_API_KEY&sessiontoken=$_sessionToken';
    try {
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _placeList = data['predictions'];
        });
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  void _requestLocationPermission() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location services are disabled',
                style: TextStyle(color: _textColor),
              ),
              backgroundColor: const Color.fromARGB(255, 57, 2, 2), // Red color from SuggestionsPage
            ));
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        _showPermissionDialog();
        return;
      }
    }
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      LocationData locationData = await Location().getLocation();
      LatLng selectedCoordinates =
      LatLng(locationData.latitude!, locationData.longitude!);
      setState(() {
        coordinates = selectedCoordinates;
        selectedLocationName = "Current Location"; // Default location
      });
      _moveCameraToPosition(selectedCoordinates);
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        title: Text('Location Permission Required',
          style: TextStyle(color: _darkTextColor, fontWeight: FontWeight.bold),
        ),
        content: Text('This app needs access to your location to function.',
          style: TextStyle(color: _darkTextColor),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Location().requestPermission();
              _requestLocationPermission();
            },
            child: Text('Grant', style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Location permission denied',
                      style: TextStyle(color: _textColor),
                    ),
                    backgroundColor: const Color.fromARGB(255, 57, 2, 2),
                  ));
            },
            child: Text('Deny', style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _moveCameraToPosition(LatLng position) async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 14));
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: InfoWindow(title: selectedLocationName ?? "Selected Location"),
        ),
      );
      coordinates = position;
    });
    // Show location confirmation dialog
    _showLocationConfirmation();
  }

  void _showLocationConfirmation() {
    if (coordinates != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location selected: ${selectedLocationName ?? "Selected Location"}',
            style: TextStyle(color: _textColor),
          ),
          backgroundColor: const Color.fromARGB(255, 2, 57, 24), // Green color from SuggestionsPage
          action: SnackBarAction(
            label: 'CONFIRM',
            textColor: Colors.white,
            onPressed: _confirmLocationSelection,
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }


  void _confirmLocationSelection() {
    if (coordinates != null) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: _cardColor,
            title: Text(
              'Confirm Location',
              style: TextStyle(
                color: _darkTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: Text(
              'Do you want to confirm this location?\n${selectedLocationName ?? "Selected Location"}',
              style: TextStyle(
                color: _darkTextColor,
                fontSize: 14,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                      color: _accentColor,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  // Return location data to previous screen
                  Navigator.pop(context, {
                    "coordinates": coordinates,
                    "name": selectedLocationName ?? "Selected Location"
                  });
                },
                child: Text(
                  'CONFIRM',
                  style: TextStyle(
                      color: _accentColor,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a location first',
            style: TextStyle(color: _textColor),
          ),
          backgroundColor: const Color.fromARGB(255, 57, 2, 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          "Location",
        ),
        backgroundColor: _backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: _textColor),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGoogle,
            markers: _markers,
            myLocationEnabled: true,
            compassEnabled: true,
            onTap: (LatLng tappedPoint) {
              setState(() {
                coordinates = tappedPoint;
                selectedLocationName = "Selected on Map";
              });
              _moveCameraToPosition(tappedPoint);
            },
            onMapCreated: (controller) {
              mapController.complete(controller);
              // Set map to dark mode to match app theme
              controller.setMapStyle('''
                [
                  {
                    "elementType": "geometry",
                    "stylers": [
                      {
                        "color": "#0f2d39"
                      }
                    ]
                  },
                  {
                    "elementType": "labels.text.fill",
                    "stylers": [
                      {
                        "color": "#746855"
                      }
                    ]
                  },
                  {
                    "elementType": "labels.text.stroke",
                    "stylers": [
                      {
                        "color": "#242f3e"
                      }
                    ]
                  }
                ]
              ''');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirmLocationSelection,
        icon: const Icon(Icons.check),
        label: const Text("Confirm"),
        backgroundColor: Color.fromARGB(255, 16, 197, 88),
        foregroundColor: _textColor,
      ),
    );
  }
}