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
  // Key to access the home page state so we can trigger early fetching
  final GlobalKey<WaterQualityHomePageState> _homeKey =
      GlobalKey<WaterQualityHomePageState>();

  @override
  void initState() {
    super.initState();
    // After the first frame, ask the home screen state to start fetching.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeKey.currentState?.startFetchingOnAppLoad();
    });
  }

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
            // GlobalKey for early fetch
            WaterQualityHomePage(key: _homeKey),

            if (_showWelcome)
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _showWelcome ? 1 : 0,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
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
