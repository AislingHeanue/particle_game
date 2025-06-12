import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:particle_game/src/core/config.dart';
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
          controller.setRandomColours();
        },
        icon: Icon(Symbols.casino),
        label: 'Random Colour',
        selected: state.selected == 0,
      ),
      Button(
        onPressed: () {
          state.selected = 1;
          controller.setColourList([
            Color(0xFFE40303),
            Color(0xFFFF8C00),
            Color(0xFFFFED00),
            Color(0xFF008026),
            Color(0xFF004CFF),
            Color(0xFF732982),
          ]);
        },
        label: '🏳️‍🌈',
        selected: state.selected == 1,
      ),
      Button(
        onPressed: () {
          state.selected = 2;
          controller.setColourList([
            Color(0xFF5BCEFA),
            Color(0xFFF5A9B8),
            Color(0xFFFFFFFF),
          ]);
        },
        label: '🏳️‍⚧️',
        selected: state.selected == 2,
      ),
      Button(
        onPressed: () {
          state.selected = 3;
          showDialog(
            context: context,
            builder: (context) {
              return Theme(
                data: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                    brightness: Brightness.dark,
                  ),
                ),
                child: AlertDialog(
                  titlePadding: const EdgeInsets.all(0),
                  contentPadding: const EdgeInsets.all(0),
                  content: SingleChildScrollView(
                    child: MaterialPicker(
                      pickerColor: state.selectedColour,
                      onColorChanged: (v) {
                        state.selectedColour = v;
                        controller.setColour(v);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
        icon: Icon(Symbols.colors),
        label: 'Pick a Colour',
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

  Color _selectedColour = initialColour;
  Color get selectedColour => _selectedColour;
  set selectedColour(Color value) {
    _selectedColour = value;
    notifyListeners();
  }
}
