import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class VetLocatorScreen extends StatefulWidget {
  const VetLocatorScreen({Key? key}) : super(key: key);

  @override
  State<VetLocatorScreen> createState() => _VetLocatorScreenState();
}

class _VetLocatorScreenState extends State<VetLocatorScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<dynamic> _places = [];
  bool _isLoading = true;

  // The user's Google Maps API Key
  static const String _placesApiKey = "AIzaSyAOVYRIgupAurZup5y1PRh8Ismb1A3lLao";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled. Please enable them.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError('Location permissions are permanently denied.');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
      _fetchNearbyVets(position.latitude, position.longitude);
    } catch (e) {
      _showError('Failed to get current location: $e');
    }
  }

  Future<void> _fetchNearbyVets(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=5000&keyword=veterinary|pet&key=$_placesApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List<dynamic>;
          setState(() {
            _places = results;
            _isLoading = false;
            _setMarkers();
          });
        } else {
          _showError('Places API Error: ${data['status']}');
        }
      } else {
        _showError('Failed to fetch places');
      }
    } catch (e) {
      _showError('Network error: $e');
    }
  }

  void _setMarkers() {
    Set<Marker> markers = {};
    
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    for (var place in _places) {
      final lat = place['geometry']['location']['lat'];
      final lng = place['geometry']['location']['lng'];
      final name = place['name'];
      final address = place['vicinity'];

      markers.add(
        Marker(
          markerId: MarkerId(place['place_id']),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name, snippet: address),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () {
            _showPlaceDetails(place);
          },
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _showPlaceDetails(dynamic place) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isOpen = place['opening_hours'] != null && place['opening_hours']['open_now'] == true;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppConstants.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.cardRadius)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                place['name'] ?? 'Vet Clinic',
                style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppConstants.textPrimary),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.orange, size: 22),
                  const SizedBox(width: 5),
                  Text(
                    '${place['rating'] ?? 'N/A'} (${place['user_ratings_total'] ?? 0} reviews)',
                    style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : AppConstants.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_rounded, color: AppConstants.primaryColor, size: 22),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      place['vicinity'] ?? 'Address not available',
                      style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : AppConstants.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (place['opening_hours'] != null)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOpen ? const Color(0xFFEAF9EE) : const Color(0xFFFFEAEA),
                        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOpen ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: isOpen ? const Color(0xFF2ECC71) : AppConstants.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOpen ? 'Open Now' : 'Closed',
                            style: GoogleFonts.fredoka(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isOpen ? const Color(0xFF2ECC71) : AppConstants.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.directions_rounded, color: Colors.white),
                  label: Text(
                    'Get Directions',
                    style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.darkCapsule,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showError(String message) {
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Find Vets Nearby 🏥',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppConstants.textPrimary),
        ),
        leading: BackButton(color: isDark ? Colors.white : AppConstants.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : _currentPosition == null
              ? Center(
                  child: Text(
                    'Location not available 📍',
                    style: GoogleFonts.fredoka(fontWeight: FontWeight.w700, fontSize: 16, color: AppConstants.textSecondary),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    zoom: 13.5,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
    );
  }
}
