import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_model.dart';

class WeatherService {
  static const String apiKey = '1d5ea4b5c7f64e4dbda154252250107';

  static Future<WeatherData?> getWeatherData(String city) async {
    final url = Uri.parse('https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&hours=24');


    try {
      final response = await http.get(url);
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WeatherData.fromJson(jsonData);
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }
}