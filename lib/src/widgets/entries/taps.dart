import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:particle_game/src/core/particle_game.dart';
import 'package:particle_game/src/widgets/has_entries.dart';
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../button.dart';

class TapsEntries with HasEntries {
  TapsEntries({required this.controller});

  Controller controller;
  @override
  List<Widget> entries(BuildContext context) {
    TapEntriesState state = context.watch<TapEntriesState>();
    return [
      Button(
        onPressed: () {
          state.selected = 0;
          controller.setTapMode(TapMode.create);
        },
        icon: Icon(Symbols.stylus),
        label: 'Clear Particles',
        selected: state.selected == 0,
      ),

      Button(
        onPressed: () {
          state.selected = 1;
          controller.setTapMode(TapMode.destroy);
        },
        icon: Icon(Symbols.ink_eraser),
        label: 'Clear Particles',
        selected: state.selected == 1,
      ),

      Button(
        onPressed: () {
          state.selected = 2;
          controller.setTapMode(TapMode.attract);
        },
        icon: Icon(Icons.cyclone),
        label: 'Clear Particles',
        selected: state.selected == 2,
      ),
    ];
  }
}

class TapEntriesState extends ChangeNotifier {
  int _selected = 0;
  int get selected => _selected;
  set selected(int value) {
    _selected = value;
    notifyListeners();
  }
}
