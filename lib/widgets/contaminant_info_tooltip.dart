import 'package:flutter/material.dart';

class ContaminantInfoTooltip extends StatelessWidget {
  final String contaminantName;
  final String shortDescription;
  final String epaLimit;
  final Color color;

  const ContaminantInfoTooltip({
    required this.contaminantName,
    required this.shortDescription,
    required this.epaLimit,
    this.color = Colors.teal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$contaminantName\n$shortDescription\n$epaLimit',
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 13,
        height: 1.4,
      ),
      preferBelow: false,
      child: Icon(
        Icons.info_outline,
        color: color,
        size: 20,
      ),
    );
  }

  static ContaminantInfoTooltip forPFOA() {
    return ContaminantInfoTooltip(
      contaminantName: 'PFOA',
      shortDescription: 'Forever chemical that persists in environment. Linked to cancer and liver damage.',
      epaLimit: 'EPA Limit: 4 ppt',
      color: Colors.blue,
    );
  }

  static ContaminantInfoTooltip forPFOS() {
    return ContaminantInfoTooltip(
      contaminantName: 'PFOS',
      shortDescription: 'Forever chemical found in firefighting foam. Affects thyroid and immune system.',
      epaLimit: 'EPA Limit: 4 ppt',
      color: Colors.purple,
    );
  }

  static ContaminantInfoTooltip forLead() {
    return ContaminantInfoTooltip(
      contaminantName: 'Lead',
      shortDescription: 'Toxic metal that damages nervous system. No safe level for children.',
      epaLimit: 'EPA Action Level: 15 ppb',
      color: Colors.red,
    );
  }

  static ContaminantInfoTooltip forNitrate() {
    return ContaminantInfoTooltip(
      contaminantName: 'Nitrate',
      shortDescription: 'From fertilizers. Can cause blue baby syndrome in infants.',
      epaLimit: 'EPA Limit: 10 ppm',
      color: Colors.orange,
    );
  }

  static ContaminantInfoTooltip forArsenic() {
    return ContaminantInfoTooltip(
      contaminantName: 'Arsenic',
      shortDescription: 'Naturally occurring element that can cause cancer and organ damage.',
      epaLimit: 'EPA Limit: 10 ppb',
      color: Colors.green,
    );
  }
}
