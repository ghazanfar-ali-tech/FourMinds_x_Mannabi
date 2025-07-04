import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_services.dart';


class DataProvider with ChangeNotifier {
  WeatherData? _weatherData;
  bool _isLoading = false;

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;

  Future<void> getWeatherData(String city) async {
    _isLoading = true;
    notifyListeners();

    try {
      _weatherData = await WeatherService.getWeatherData(city);
    } catch (e) {
      print('Error fetching weather data: $e');
      _weatherData = null;
    }

    _isLoading = false;
    notifyListeners();
  }
}