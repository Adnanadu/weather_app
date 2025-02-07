import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_model.dart';

class WeatherService {
  static const baseUrl = "https://api.openweathermap.org/data/2.5/weather";
  final String apiKey;
  WeatherService(this.apiKey);
  Future<WeatherModel> getWeather(String cityName) async {
    try {
      // Encode the city name to handle spaces and special characters
      final encodedCity = Uri.encodeComponent(cityName.trim());
      final url = '$baseUrl?q=$encodedCity&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        throw Exception('Invalid request. Please check city name format');
      } else if (response.statusCode == 404) {
        throw Exception('City not found: $cityName');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key');
      } else {
        throw Exception(
            'Failed to load weather data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format from weather service');
      }
      throw Exception('Failed to connect to weather service: ${e.toString()}');
    }
  }

  Future<String> getCurrentCity() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    /// Get the current position
    Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
      timeLimit: Duration(seconds: 10),
    ));

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    String? city = placemarks[0].locality;
    if (city == null || city.isEmpty) {
      // Fallback to administrative area if locality is not available
      city = placemarks[0].administrativeArea;
    }
    return city ?? "London"; // Fallback to a default city if no location found
  }
}
