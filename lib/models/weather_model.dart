class WeatherModel {
  final String cityName;
  final double temperature;
  final String mainContinion;

  WeatherModel({required this.cityName, required this.temperature, required this.mainContinion});

factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainContinion: json['weather'][0]['main'],
    );
  }
}
