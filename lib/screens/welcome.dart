import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  final VoidCallback onClose;
  const Welcome({super.key, required this.onClose});
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  int _step = 0;
  final List<Map<String, dynamic>> _instructions = [
    {
      "title": "Welcome to WaterWise",
      "description": "Your comprehensive water quality monitoring companion",
      "icon": Icons.water_drop_sharp,
    },
    {
      "title": "Track Water Quality",
      "description": "Monitor PFOA, PFOS, Lead, Nitrate, and Arsenic levels in your community's water supply",
      "icon": Icons.science,
    },
    {
      "title": "Find Nearby Data",
      "description": "Click 'My Location' to discover water quality testing sites in your area",
      "icon": Icons.my_location,
    },
    {
      "title": "Explore Other Areas",
      "description": "Search any city, state, or ZIP code to check water quality across the country",
      "icon": Icons.search,
    },
    {
      "title": "Compare & Analyze",
      "description": "View historical trends and compare contaminant levels over time",
      "icon": Icons.dashboard,
    },
    {
      "title": "Stay Informed",
      "description": "Learn about contaminants and their health impacts with our educational resources",
      "icon": Icons.info,
    },
  ];

  void _nextStep() {
    setState(() {
      if (_step < 5) {
        _step++;
      } else {
        widget.onClose();
      }
    });
  }

  void _beforeStep() {
    setState(() {
      if (_step > 0) {
        _step--;
      } else {
        widget.onClose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _instructions[_step];
    return Stack(
      children: [
        FractionallySizedBox(
          widthFactor: 0.85,
          heightFactor: 0.75,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.teal.shade50, Colors.blue.shade50],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 50, vertical: 40),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon for current step
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          currentStep['icon'],
                          size: 60,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        currentStep['title'],
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currentStep['description'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Progress indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _instructions.length,
                          (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: _step == index ? 12 : 8,
                            height: _step == index ? 12 : 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _step == index
                                  ? Colors.teal
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_step > 0)
                            ElevatedButton.icon(
                              onPressed: _beforeStep,
                              icon: Icon(Icons.arrow_back),
                              label: const Text('Back'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.grey.shade800,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          if (_step > 0) const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _nextStep,
                            icon: Icon(_step == 5 ? Icons.check : Icons.arrow_forward),
                            label: Text(_step == 5 ? 'Get Started' : 'Next'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
