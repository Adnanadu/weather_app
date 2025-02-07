import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/core/secret/env/env.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  ///apikey
  final weatherService = WeatherService(Env.apiKey);
  WeatherModel? weatherModel;

  ///fetch weather
  void fetchWeather() async {
    try {
      String cityName = await weatherService.getCurrentCity();
      WeatherModel weather = await weatherService.getWeather(cityName);
      setState(() {
        weatherModel = weather;
      });
    } catch (e) {
      log(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                fetchWeather();
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  ///weather animation
  String getWeatherAnimations(String? mainCondition) {
    if (mainCondition == null) return 'assets/animations/sunny.json';
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/animations/cloud.json';
      case 'rain':
      case 'drizzle':
        return 'assets/animations/rain.json';
      case 'shower rain':
      case 'thunderstorm':
        return 'assets/animations/rain_with_thunder.json';
      case 'clear': // changed from 'Clear' to lowercase
        return 'assets/animations/sunny.json';
      case '':
        return 'assets/animations/sunny.json';
      default:
        return 'assets/animations/cloud.json';
    }
  }

  ///init state
  @override
  void initState() {
    fetchWeather();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: fetchWeather,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //city name
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // removed const
                Icon(
                  Icons.location_on,
                  color: Colors.grey,
                  size: 30,
                ),
                Text(
                  weatherModel?.cityName ?? 'Loading City...!',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            //animations
            Lottie.asset(getWeatherAnimations(weatherModel?.mainCondition)),

            ///temperature
            Text(
              weatherModel?.temperature != null
                  ? "${weatherModel!.temperature.toStringAsFixed(1)} °C"
                  : "-- °C",
              style: const TextStyle(
                // added const
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
