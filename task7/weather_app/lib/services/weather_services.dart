import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/forecastModel.dart';
import 'package:weather_app/models/weather_model.dart';

class WeatherService {
  static const String apiKey = '1d5ea4b5c7f64e4dbda154252250107';

  static Future<WeatherData?> getWeatherData(String city) async {
    final url = Uri.parse('https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&hours=24');

    try {
      // print('Making API call for city: $city at ${DateTime.now()}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      // print('API Response for $city - Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WeatherData.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        final jsonData = json.decode(response.body);
        if (jsonData['error'] != null && jsonData['error']['code'] == 1006) {
          throw Exception('LOCATION_NOT_FOUND');
        }
        throw Exception('API_ERROR: ${response.statusCode}');
      } else {
        throw Exception('API_ERROR: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in WeatherService for $city: $e');
      rethrow;
    }
  }
  static Future<ForeCastModel?> getForecastData(String city) async {
    final url = Uri.parse('https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=1');

    try {
      print('Making forecast API call for city: $city at ${DateTime.now()}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      print('Forecast API Response for $city - Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ForeCastModel.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        final jsonData = json.decode(response.body);
        if (jsonData['error'] != null && jsonData['error']['code'] == 1006) {
          throw Exception('LOCATION_NOT_FOUND');
        }
        throw Exception('API_ERROR: ${response.statusCode}');
      } else {
        throw Exception('API_ERROR: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in WeatherService forecast for $city: $e');
      rethrow;
    }
  }
}