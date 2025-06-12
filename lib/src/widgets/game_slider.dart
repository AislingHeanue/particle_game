import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './expandable_menu.dart';

class GameSlider extends StatelessWidget {
  const GameSlider({
    super.key,
    required this.visible,
    required this.variable,
    required this.onChanged,
  });

  final bool visible;
  final double variable;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    var menuState = context.watch<ExpandableMenuState>();
    return Visibility(
      visible: visible && !menuState.menuMoving,
      child: SizedBox(
        width: 200,
        height: 40,
        child: Slider(value: variable, onChanged: onChanged),
      ),
    );
  }
}
