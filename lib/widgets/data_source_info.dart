import 'package:flutter/material.dart';

class DataSourceInfo extends StatelessWidget {
  const DataSourceInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.source, color: Colors.teal, size: 16),
            const SizedBox(width: 8),
            Text(
              'Data Source: EPA Water Quality Portal',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'This application uses real water quality data from the EPA\'s Water Quality Portal, which aggregates data from USGS, EPA STORET, and other sources.',
              child: Icon(Icons.help_outline, size: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
