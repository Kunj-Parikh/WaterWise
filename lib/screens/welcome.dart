import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  final VoidCallback onClose;
  const Welcome({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FractionallySizedBox(
          widthFactor: 0.7,
          heightFactor: 0.5,
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 50, vertical: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, right: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            'Welcome to WaterWise',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Find out about nearby water quality data of PFOA, lead, nitrate, and aresnic. Start by clicking "My Location "',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black, fontSize: 22),
                          ),
                          const SizedBox(height: 50),
                          ElevatedButton(
                            onPressed: onClose,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                255,
                                255,
                                255,
                              ),
                              foregroundColor: const Color.fromARGB(
                                255,
                                0,
                                0,
                                0,
                              ),
                            ),
                            child: const Text('Go.'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
