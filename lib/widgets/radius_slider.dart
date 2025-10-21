import 'package:flutter/material.dart';

class RadiusSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int divisions;
  final String? label;

  const RadiusSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 1,
    this.max = 50,
    this.divisions = 49,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.circle, size: 18, color: Colors.teal),
        const SizedBox(width: 8),
        SizedBox(
          width: 160,
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: label ?? '${value.toStringAsFixed(1)} mi',
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${value.toStringAsFixed(1)} mi',
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
