import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class PlacesService {
  // PASTE YOUR GOOGLE API KEY HERE
  static const String apiKey = "AIzaSyAsuotiC9JPuX0n1EWEvUYJ-Qi8rMtBFZM"; 

  // 1. Get the user's current GPS location
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    } 

    return await Geolocator.getCurrentPosition();
  }

  // 2. Fetch Vets from Google based on that location
  Future<List<dynamic>> getNearbyVets() async {
    try {
      // Get the phone's current location
      Position position = await _determinePosition();
      
      // Build the Google Places URL 
      // radius=5000 means a 5 kilometer radius. type=veterinary_care targets vets.
      final String url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
          "?location=${position.latitude},${position.latitude}"
          "&radius=5000"
          "&type=veterinary_care"
          "&key=$apiKey";

      // Make the network request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Decode the JSON and return the 'results' array
        final data = json.decode(response.body);
        return data['results']; 
      } else {
        throw Exception('Failed to load Google Places');
      }
    } catch (e) {
      print("Error fetching vets: $e");
      return [];
    }
  }
}