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
    ///get current city
    String cityName = await weatherService.getCurrentCity();

    ///get weather city
    try {
      WeatherModel weather = await weatherService.getWeather(cityName);
      setState(() {
        weatherModel = weather;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  ///weather animation
  String getWeatherAnimations(String? mainCondition) {
    switch (mainCondition) {
      case 'Clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/animations/cloud.json';
      case 'Rain':
      case 'drizzle':
        return 'assets/animations/rain.json';
      case 'shower rain':
      case 'thunderstorm':
        return 'assets/animations/rain_with_thunder.json';
      case 'Clear':
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //city name
            Column(
              spacing: 10,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.grey,
                  size: 30,
                ),
                Text(weatherModel?.cityName ?? 'Loading City...!',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
              ],
            ),

            //animations
            Lottie.asset(getWeatherAnimations(weatherModel?.mainContinion)),

            ///temperature
            Text(
              "${weatherModel?.temperature} °C",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
