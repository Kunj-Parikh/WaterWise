import 'package:flutter/material.dart';

// display label -> internal value
const Map<String, String> contaminantOptions = {
  'Every Contaminant': 'Every Contaminant',
  'PFOA ion': 'PFOAion',
  'Lead': 'Lead',
  'Nitrate': 'Nitrate',
  'Arsenic': 'Arsenic',
};

// Icons for each contaminant
const Map<String, IconData> contaminantIcons = {
  'Every Contaminant': Icons.water_drop,
  'PFOA ion': Icons.science,
  'Lead': Icons.dangerous,
  'Nitrate': Icons.agriculture,
  'Arsenic': Icons.landscape,
};

// Colors for each contaminant
const Map<String, Color> contaminantMenuColors = {
  'Every Contaminant': Colors.teal,
  'PFOA ion': Colors.blue,
  'Lead': Colors.red,
  'Nitrate': Colors.orange,
  'Arsenic': Colors.green,
};

class DropDown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  const DropDown({super.key, this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    // find display label for the current value
    String? displayValue = contaminantOptions.entries
        .firstWhere(
          (e) => e.value == value,
          orElse: () => contaminantOptions.entries.first,
        )
        .key;
    return DropdownButton<String>(
      value: displayValue,
      isExpanded: true,
      elevation: 8,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      underline: Container(
        height: 0,
      ),
      icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(8),
      onChanged: (String? label) {
        if (onChanged != null) {
          onChanged!(contaminantOptions[label!]);
        }
      },
      items: contaminantOptions.keys.map<DropdownMenuItem<String>>((
        String label,
      ) {
        final icon = contaminantIcons[label] ?? Icons.water_drop;
        final color = contaminantMenuColors[label] ?? Colors.teal;
        return DropdownMenuItem<String>(
          value: label,
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class FilterMenuBar extends StatefulWidget {
  const FilterMenuBar({super.key});

  @override
  State<FilterMenuBar> createState() => _FilterMenuBarState();
}

class _FilterMenuBarState extends State<FilterMenuBar> {
  String valueSelected = contaminantOptions.values.first;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      padding: const EdgeInsets.all(20.0),
      // alignment: Alignment.bottomLeft,
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView(
        shrinkWrap: true,
        children: [
          // Add more if needed, also we can switch to single selection instead of checkboxes
          // CheckBox(label: "Every Contaminant"),
          // CheckBox(label: "PFAs"),
          // CheckBox(label: "PFAOs"),
          // CheckBox(label: "Nitrogen"),
          // CheckBox(label: "Phosphorus"),
          // CheckBox(label: "Lead"),
          DropDown(
            value: valueSelected,
            onChanged: (String? value) {
              setState(() {
                valueSelected = value!;
              });
            },
          ),
        ],
      ),
    );
  }
}
