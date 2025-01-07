import 'package:flutter/material.dart';
import 'package:simple_weather_app/screens/SplashScreen.dart'; // Import your custom splash screen
import 'package:simple_weather_app/screens/home_screen.dart'; // Import your custom home screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ani Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
