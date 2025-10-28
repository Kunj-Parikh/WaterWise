import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  final VoidCallback onClose;
  const Welcome({super.key, required this.onClose});
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  int _step = 0;
  final List<String> _instructions = [
    "Learn about how WaterWise can help you and your community:",
    "Find out about nearby water quality data of PFOA, lead, nitrate, and arsenic",
    "Start by clicking \"My Location.\"",
    "Also find about water quality data from other areas.",
    "Compare different contaminant levels and historical levels.",
    "Start!",
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
    return Stack(
      children: [
        FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.7,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 50, vertical: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, right: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              'Welcome to WaterWise',
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _instructions[_step],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 30),
                            ),
                            const SizedBox(height: 50),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _nextStep,
                                  child: Text(_step == 5 ? 'Go!' : 'Next'),
                                ),

                                if (_step > 0)
                                  ElevatedButton(
                                    onPressed: _beforeStep,
                                    child: const Text('Go Back'),
                                  ),
                              ],
                            ),

                            // Container(
                            //   child: ElevatedButton(
                            //     onPressed: onClose,
                            //     style: ElevatedButton.styleFrom(
                            //       backgroundColor: const Color.fromARGB(
                            //         255,
                            //         255,
                            //         255,
                            //         255,
                            //       ),
                            //       foregroundColor: const Color.fromARGB(
                            //         255,
                            //         0,
                            //         0,
                            //         0,
                            //       ),
                            //     ),
                            //     child: const Text(
                            //       'Go.',
                            //       textAlign: TextAlign.center,
                            //       style: TextStyle(fontSize: 30),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
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
