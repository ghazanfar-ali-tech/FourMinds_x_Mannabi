import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_services.dart';


class DataProvider with ChangeNotifier {
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getWeatherData(String city) async {
    _isLoading = true;
      _errorMessage = null;
    notifyListeners();

    try {
      _weatherData = await WeatherService.getWeatherData(city);
    } catch (e) {
      print('Error fetching weather data: $e');
      _weatherData = null;
        if (e.toString().contains('LOCATION_NOT_FOUND')) {
        _errorMessage = 'Location not found.';
      } else {
        _errorMessage = 'Failed to fetch weather data.';
      }
    }

    _isLoading = false;
    notifyListeners();
  }
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}