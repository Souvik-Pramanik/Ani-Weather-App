import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_weather_app/services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final WeatherService weatherService = WeatherService();
  final TextEditingController cityController = TextEditingController();
  String? cityName;
  String? temperature;
  String? description;
  String? humidity;
  String? windSpeed;
  String? icon;
  bool isDayTime = true;
  List<dynamic>? weeklyForecast; // Store 7-day forecast data

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  void getWeather() async {
    final weatherData = await weatherService.fetchWeather(cityController.text);
    if (weatherData != null) {
      setState(() {
        cityName = weatherData['name'];
        temperature = '${weatherData['main']['temp']}°C';
        description = weatherData['weather'][0]['description'];
        humidity = '${weatherData['main']['humidity']}%';
        windSpeed = '${weatherData['wind']['speed']} m/s';
        icon = weatherData['weather'][0]['icon'];

        // Determine if it's day or night
        int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        int sunrise = weatherData['sys']['sunrise'];
        int sunset = weatherData['sys']['sunset'];
        isDayTime = currentTime >= sunrise && currentTime < sunset;
      });

      // Fetch 7-day forecast
      final forecast = await weatherService.fetch7DayForecast(
        weatherData['coord']['lat'],
        weatherData['coord']['lon'],
      );
      print('Fetched Forecast Data: $forecast');

      if (forecast != null) {
        setState(() {
          weeklyForecast = forecast;
        });
        print('Weekly Forecast Updated: $weeklyForecast');
      }

      _controller.forward(from: 0.0);
    } else {
      setState(() {
        cityName = null;
        temperature = null;
        description = null;
        humidity = null;
        windSpeed = null;
        icon = null;
        weeklyForecast = null;
      });
      print('City not found.');
    }
  }

  void getWeatherByLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permission denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permission permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final weatherData = await weatherService.fetchWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      if (weatherData != null) {
        setState(() {
          cityName = weatherData['name'];
          temperature = '${weatherData['main']['temp']}°C';
          description = weatherData['weather'][0]['description'];
          humidity = '${weatherData['main']['humidity']}%';
          windSpeed = '${weatherData['wind']['speed']} m/s';
          icon = weatherData['weather'][0]['icon'];

          // Determine if it's day or night
          int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          int sunrise = weatherData['sys']['sunrise'];
          int sunset = weatherData['sys']['sunset'];
          isDayTime = currentTime >= sunrise && currentTime < sunset;
        });

        // Fetch 7-day forecast
        final forecast = await weatherService.fetch7DayForecast(
          position.latitude,
          position.longitude,
        );
        print('Fetched Forecast Data: $forecast');

        if (forecast != null) {
          setState(() {
            weeklyForecast = forecast;
          });
          print('Weekly Forecast Updated: $weeklyForecast');
        }

        _controller.forward(from: 0.0);
      } else {
        setState(() {
          cityName = null;
          temperature = null;
          description = null;
          humidity = null;
          windSpeed = null;
          icon = null;
          weeklyForecast = null;
        });
        print('Unable to fetch weather for the current location.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget build7DayForecast() {
    if (weeklyForecast == null) {
      return Center(
        child: Text(
          'No forecast data available.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '7-Day Forecast',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weeklyForecast!.length,
            itemBuilder: (context, index) {
              final day = weeklyForecast![index];
              final icon = day['weather'][0]['icon'];
              final temp = day['temp']['day'].toStringAsFixed(1);
              final date =
                  DateTime.fromMillisecondsSinceEpoch(day['dt'] * 1000);

              return Card(
                margin: EdgeInsets.only(right: 10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${[
                          'Sun',
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat'
                        ][date.weekday % 7]}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Image.network(
                        'https://openweathermap.org/img/wn/$icon@2x.png',
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(height: 10),
                      Text('$temp°C'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget getWeatherAnimation() {
    if (icon == null) return SizedBox.shrink();

    if (icon!.contains("01")) {
      // Clear Sky
      return Lottie.asset('assets/animations/clear_sky.json',
          fit: BoxFit.cover);
    } else if (icon!.contains("02") ||
        icon!.contains("03") ||
        icon!.contains("04")) {
      // Cloudy
      return Lottie.asset('assets/animations/cloudy.json', fit: BoxFit.cover);
    } else if (icon!.contains("09")) {
      // Drizzle
      return Lottie.asset('assets/animations/drizzle.json', fit: BoxFit.cover);
    } else if (icon!.contains("10")) {
      // Rain
      return Lottie.asset('assets/animations/rain.json', fit: BoxFit.cover);
    } else if (icon!.contains("11")) {
      // Thunderstorm
      return Lottie.asset('assets/animations/thunderstorm.json',
          fit: BoxFit.cover);
    } else if (icon!.contains("13")) {
      // Snow
      return Lottie.asset('assets/animations/snow.json', fit: BoxFit.cover);
    } else if (icon!.contains("50")) {
      // Mist or Atmosphere
      return Lottie.asset('assets/animations/mist.json', fit: BoxFit.cover);
    } else {
      // Fallback for unknown icons
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: getWeatherAnimation(),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Text(
                  'Ani Weather App',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 199, 105, 239),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter City Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: getWeather,
                      child: Text('Get Weather'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: getWeatherByLocation,
                      child: Text('Get Weather by Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                if (cityName != null)
                  Expanded(
                    child: ListView(
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Card(
                            color: Colors.white.withOpacity(0.8),
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (icon != null)
                                    Image.network(
                                      'https://openweathermap.org/img/wn/$icon@2x.png',
                                      width: 100,
                                      height: 100,
                                    ),
                                  Text(
                                    'Weather in $cityName',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Temperature: $temperature',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black87),
                                  ),
                                  Text(
                                    'Condition: $description',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black87),
                                  ),
                                  Text(
                                    'Humidity: $humidity',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black87),
                                  ),
                                  Text(
                                    'Wind Speed: $windSpeed',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        build7DayForecast(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
