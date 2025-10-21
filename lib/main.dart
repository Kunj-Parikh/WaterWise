import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/welcome.dart';

void main() {
  runApp(WaterWiseApp());
}

class WaterWiseApp extends StatefulWidget {
  const WaterWiseApp({super.key});

  @override
  State<WaterWiseApp> createState() => _WaterWiseAppState();
}

class _WaterWiseAppState extends State<WaterWiseApp> {
  bool _showWelcome = true;

  void _closeWelcome() {
    setState(() {
      _showWelcome = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WaterWise',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _showWelcome
          ? Welcome(onClose: _closeWelcome)
          : WaterQualityHomePage(),
    );
  }
}
