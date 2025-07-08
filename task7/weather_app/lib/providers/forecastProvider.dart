import 'package:flutter/material.dart';
import 'package:weather_app/models/forecastModel.dart';
import 'package:weather_app/services/weather_services.dart';


class ForecastProvider with ChangeNotifier {
  ForeCastModel? _forecastData;
  bool _isLoading = false;
  String? _errorMessage;

  ForeCastModel? get forecastData => _forecastData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getForecastData(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final weatherData = await WeatherService.getForecastData(city);
      _forecastData = weatherData != null ? ForeCastModel.fromJson(weatherData.toJson()) : null;
    } catch (e) {
      print('Error fetching forecast data: $e');
      _forecastData = null;
      if (e.toString().contains('LOCATION_NOT_FOUND')) {
        _errorMessage = 'Location not found.';
      } else {
        _errorMessage = 'Failed to fetch forecast data.';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearForecastData() {
    _forecastData = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}