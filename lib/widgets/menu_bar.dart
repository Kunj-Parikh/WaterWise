import 'package:flutter/material.dart';

// display label -> internal value
const Map<String, String> contaminantOptions = {
  'Every Contaminant': 'Every Contaminant',
  'PFOA ion': 'PFOAion',
  'Lead': 'Lead',
  'Nitrate': 'Nitrate',
  'Arsenic': 'Arsenic',
};

class DropDown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  const DropDown({Key? key, this.value, this.onChanged}) : super(key: key);

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
      elevation: 16,
      style: const TextStyle(color: Color.fromARGB(255, 10, 3, 116)),
      underline: Container(
        height: 2,
        color: const Color.fromARGB(255, 70, 2, 255),
      ),
      onChanged: (String? label) {
        if (onChanged != null) {
          onChanged!(contaminantOptions[label!]);
        }
      },
      items: contaminantOptions.keys.map<DropdownMenuItem<String>>((
        String label,
      ) {
        return DropdownMenuItem<String>(value: label, child: Text(label));
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
