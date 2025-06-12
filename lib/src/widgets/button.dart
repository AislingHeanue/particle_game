import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './expandable_menu.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.onPressed,
    required this.label,
    this.direction,
    bool? selected,
    this.icon,
  }) : selected = selected ?? false;

  final VoidCallback? onPressed;
  final Widget? icon;
  final String label;
  final Axis? direction;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    ExpandableMenuState menuState = context.watch<ExpandableMenuState>();
    late final Widget button;
    if (menuState.showTooltips && !menuState.menuMoving) {
      button = SizedBox(
        width: 165,
        child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: icon,
              label: Text(label),
              style: ElevatedButton.styleFrom(
                iconSize: 24,
                padding: EdgeInsets.only(left: 8, right: 16),
                foregroundColor: menuState.buttonForegroundColour,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
      );
    } else if (icon != null) {
      button = IconButton(
        onPressed: onPressed,
        icon: icon!,
        tooltip: label,
        iconSize: 24,
        style: IconButton.styleFrom(
          foregroundColor: menuState.buttonForegroundColour,
          backgroundColor: selected ? Colors.lightBlue[200] : Colors.white,
        ),
      );
    } else {
      button = Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: SizedBox(
          width: 40,
          height: 40,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.only(left: 0, right: 0),
              foregroundColor: menuState.buttonForegroundColour,
              backgroundColor: selected ? Colors.lightBlue[200] : Colors.white,
            ),
            child: Text(label),
          ),
        ),
      );
    }

    return direction == Axis.horizontal
        ? Container(
            width: 40,
            margin: EdgeInsetsGeometry.only(left: 7.0),
            child: button,
          )
        : Container(
            height: 40,
            margin: EdgeInsetsGeometry.only(top: 7.0),
            child: button,
          );
  }
}
