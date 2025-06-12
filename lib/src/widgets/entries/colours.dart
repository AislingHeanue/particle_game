import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:particle_game/src/widgets/has_entries.dart';
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../button.dart';

class ColoursEntries with HasEntries {
  ColoursEntries({required this.controller});

  Controller controller;
  @override
  List<Widget> entries(BuildContext context) {
    ColoursEntriesState state = context.watch<ColoursEntriesState>();
    return [
      Button(
        onPressed: () {
          state.selected = 0;
        },
        icon: Icon(Symbols.brush),
        label: 'Not Implemented',
        selected: state.selected == 0,
      ),
      Button(
        onPressed: () {
          state.selected = 1;
        },
        icon: Icon(Symbols.brush),
        label: 'Not Implemented',
        selected: state.selected == 1,
      ),
      Button(
        onPressed: () {
          state.selected = 2;
        },
        icon: Icon(Symbols.brush),
        label: 'Not Implemented',
        selected: state.selected == 2,
      ),
      Button(
        onPressed: () {
          state.selected = 3;
        },
        icon: Icon(Symbols.brush),
        label: 'Not Implemented',
        selected: state.selected == 3,
      ),
    ];
  }
}

class ColoursEntriesState extends ChangeNotifier {
  int _selected = 0;
  int get selected => _selected;
  set selected(int value) {
    _selected = value;
    notifyListeners();
  }
}
