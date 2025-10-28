import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/welcome.dart';

void main() {
  runApp(const WaterWiseApp());
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

      home: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          alignment: Alignment.center,
          children: [
            const WaterQualityHomePage(),

            if (_showWelcome)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showWelcome ? 1 : 0,
                child: Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(child: Welcome(onClose: _closeWelcome)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
