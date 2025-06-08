import 'package:flutter/material.dart';

class _CheckBoxState extends State<CheckBox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label),
        const SizedBox(width: 8),
        Checkbox(
          checkColor: Colors.white,
          fillColor: WidgetStateProperty.resolveWith(getColor),
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value!;
            });
          },
        )
      ]
    );
  }
}

class FilterMenuBar extends StatefulWidget {
  const FilterMenuBar({super.key});

  @override
  State<FilterMenuBar> createState() => _FilterMenuBarState();
}

class CheckBox extends StatefulWidget {
  final String label;
  const CheckBox({super.key, required this.label});

  @override
  State<CheckBox> createState() => _CheckBoxState();
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
          CheckBox(label: "PFAs"),
          CheckBox(label: "PFAOs"),
          CheckBox(label: "Nitrogen"),
          CheckBox(label: "Phosphorus"),
          CheckBox(label: "Lead"),
        ],
      ),
    );
  }
}