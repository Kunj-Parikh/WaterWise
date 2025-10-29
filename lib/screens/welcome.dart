import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  final VoidCallback onClose;
  const Welcome({super.key, required this.onClose});
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  int _step = 0;
  int _tdirection = 1;
  final List<String> _instructions = [
    "Learn about how WaterWise can help you and your community.",
    "Find out about nearby water quality data of PFOA, lead, nitrate, and arsenic.",
    "Visualize data through heat maps.",
    "Find about water quality data in other areas.",
    "Compare different contaminant levels and historical levels.",
    "Let's Go!",
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
    final List<String> _images = [
      '../pictures/map.jpg',
      '/pictures/heatmap.jpg',
      '/pictures/search.jpg',
      '/pictures/graph.png',
    ];
    return Stack(
      children: [
        FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.7,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: FractionallySizedBox(
                  heightFactor: 1,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder:
                                    (
                                      Widget child,
                                      Animation<double> animation,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position:
                                              Tween<Offset>(
                                                begin: Offset(
                                                  0.1 * _tdirection,
                                                  0,
                                                ),
                                                end: Offset.zero,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeOut,
                                                ),
                                              ),
                                          child: child,
                                        ),
                                      );
                                    },
                                child: Text(
                                  _instructions[_step],
                                  key: ValueKey(_step),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 30),
                                ),
                              ),

                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder:
                                    (
                                      Widget child,
                                      Animation<double> animation,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position:
                                              Tween<Offset>(
                                                begin: Offset(
                                                  0.1 * _tdirection,
                                                  0,
                                                ),
                                                end: Offset.zero,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeOut,
                                                ),
                                              ),
                                          child: child,
                                        ),
                                      );
                                    },
                                child: (_step > 0 && _step <= 4)
                                    ? Container(
                                        key: ValueKey(_step),
                                        height: 100,
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          _images[_step - 1],
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : const SizedBox(
                                        key: ValueKey(-1),
                                        height: 100,
                                      ),
                              ),

                              const SizedBox(height: 50),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [
                                  Opacity(
                                    opacity: _step > 0 ? 1 : 0,
                                    child: ElevatedButton(
                                      onPressed: _beforeStep,
                                      child: const Text('Go Back'),
                                    ),
                                  ),

                                  ElevatedButton(
                                    onPressed: _nextStep,
                                    child: Text(_step == 5 ? 'Go!' : 'Next'),
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
        ),
      ],
    );
  }
}
