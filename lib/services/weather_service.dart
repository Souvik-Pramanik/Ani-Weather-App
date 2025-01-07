import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '78a94226c701e8a20d5de58a29dff67d';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // Method to fetch weather by city name
  Future<Map<String, dynamic>?> fetchWeather(String city) async {
    try {
      final url = Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error: Unable to fetch weather data.');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<dynamic>?> fetch7DayForecast(
      double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=$latitude&lon=$longitude&exclude=current,minutely,hourly,alerts&units=metric&appid=78a94226c701e8a20d5de58a29dff67d');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['daily'];
    } else {
      print('Failed to fetch 7-day forecast');
      return null;
    }
  }

  // Method to fetch weather by GPS location
  Future<Map<String, dynamic>?> fetchWeatherByLocation(
      double latitude, double longitude) async {
    try {
      final url = Uri.parse(
          '$baseUrl?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error: Unable to fetch weather data by location.');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
