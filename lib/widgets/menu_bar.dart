import 'package:flutter/material.dart';

List<String> contaminants = <String>['Every Contaminant', 'PFAs', 'PFAOs', 'Nitrogen', 'Phosphorus', 'Lead'];

class _DropDownState extends State<DropDown> {
  String valueSelected = contaminants.first;
  @override
  Widget build(BuildContext context) {

    return DropdownButton<String>(
      value: valueSelected,
      elevation: 16,
      style: const TextStyle(color: Color.fromARGB(255, 10, 3, 116)),
      underline: Container(height: 2, color: const Color.fromARGB(255, 70, 2, 255)),
      onChanged: (String? value) {
        setState(() {
          valueSelected = value!;
        });
      },
      items: 
        contaminants.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
    );
  }
}

class FilterMenuBar extends StatefulWidget {
  const FilterMenuBar({super.key});

  @override
  State<FilterMenuBar> createState() => _FilterMenuBarState();
}

class DropDown extends StatefulWidget {
  // final String label;
  const DropDown({super.key});

  @override
  State<DropDown> createState() => _DropDownState();
}


class _FilterMenuBarState extends State<FilterMenuBar> {
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
          DropDown()
        ],
      ),
    );
  }
}