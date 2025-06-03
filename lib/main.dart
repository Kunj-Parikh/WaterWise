import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
void main() {
  runApp(WaterWiseApp());
}

class WaterWiseApp extends StatelessWidget {
  const WaterWiseApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaterWise',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WaterQualityHomePage(),
    );
  }
}
