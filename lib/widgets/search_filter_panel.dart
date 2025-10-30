import 'dart:math';

import 'package:flutter/material.dart';
import 'radius_slider.dart';

class SearchFilterPanel extends StatelessWidget {
  final double radius;
  final ValueChanged<double> onRadiusChanged;
  final ValueChanged<double>? onRadiusChangeEnd;
  final Widget menuBar;
  final Widget searchBox;
  final VoidCallback onMyLocationPressed;
  final VoidCallback onRefreshPressed;
  final Widget filterRow;
  final bool showSidebar;
  final bool showInfoPanel;

  const SearchFilterPanel({
    super.key,
    required this.radius,
    required this.onRadiusChanged,
    this.onRadiusChangeEnd,
    required this.menuBar,
    required this.searchBox,
    required this.onMyLocationPressed,
    required this.onRefreshPressed,
    required this.filterRow,
    required this.showSidebar,
    this.showInfoPanel = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Reserve 480px on the right so the panel doesn't overlap the sidebar close button
    final double reservedRightForSidebar = showSidebar ? 480.0 : 0.0;
    // Also reserve some right margin for floating buttons (heatmap/dashboard)
    final double floatingButtonsRightMargin = 160.0;
    final double rightInset =
        (reservedRightForSidebar + floatingButtonsRightMargin).clamp(
          8.0,
          screenWidth - 80.0,
        );

    final leftInset = showInfoPanel ? 350.0 : 0.0;

    return Positioned(
      top: 0,
      left: leftInset,
      right: rightInset,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 280.0,
          maxWidth: min(900.0, screenWidth - leftInset - rightInset - 16.0),
        ),
        child: Container(
          color: Colors.white.withValues(alpha: 0.95),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              menuBar,
              const SizedBox(height: 8),
              searchBox,
              const SizedBox(height: 8),
              RadiusSlider(
                value: radius,
                onChanged: onRadiusChanged,
                onChangeEnd: onRadiusChangeEnd,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: onMyLocationPressed,
                    child: const Text('My Location'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onRefreshPressed,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              filterRow,
            ],
          ),
        ),
      ),
    );
  }
}
