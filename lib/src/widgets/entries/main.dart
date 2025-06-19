import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:particle_game/src/widgets/entries/taps.dart';
import 'package:particle_game/src/widgets/expandable_menu.dart';
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../core/config.dart';
import '../button.dart';
import '../game_slider.dart';
import '../has_entries.dart';
import 'colours.dart';

class MainEntries with HasEntries {
  MainEntries({required this.controller});

  Controller controller;

  @override
  List<Widget> entries(BuildContext context) {
    var state = context.watch<MainEntriesState>();
    var parentState = context.watch<ExpandableMenuState>();
    return [
      Button(
        onPressed: () {
          parentState.toggleTooltips();
        },
        icon: Icon(Icons.question_mark),
        label: 'Show Help',
      ),
      Button(
        onPressed: () {
          state.paused = !state.paused;
          if (state.paused) {
            controller.pause();
            state.playPauseIcon = Icon(Icons.play_arrow);
            state.playPauseLabel = 'Resume';
          } else {
            controller.play();
            state.playPauseIcon = Icon(Icons.pause);
            state.playPauseLabel = 'Pause';
          }
        },
        icon: state.playPauseIcon,
        label: state.playPauseLabel,
      ),
      Button(
        onPressed: controller.spawnParticles,
        icon: Icon(Icons.grain),
        label: 'Create Particles',
      ),
      Button(
        onPressed: controller.reset,
        icon: Icon(Icons.close),
        label: 'Clear Particles',
      ),
      Button(
        onPressed: controller.freezeParticles,
        icon: Icon(Icons.ac_unit), // snowflake
        label: 'Freeze Particles',
      ),
      ChangeNotifierProvider(
        create: (context) => TapEntriesState(),
        child: ExpandableMenu(
          spin: 1,
          direction: Axis.horizontal,
          icon: Icon(Icons.touch_app),
          child: TapsEntries(controller: controller),
          label: 'Touch Options',
          normalButton: true,
          parent: parentState,
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => ColoursEntriesState(),
        child: ExpandableMenu(
          spin: 1,
          direction: Axis.horizontal,
          icon: Icon(Icons.palette),
          child: ColoursEntries(controller: controller),
          label: 'Particle Colours',
          normalButton: true,
          parent: parentState,
        ),
      ),
      Row(
        children: [
          Button(
            onPressed: () {
              state.gravityBarVisible = !state.gravityBarVisible;
            },
            icon: Icon(Symbols.weight),
            label: 'Gravity',
          ),
          GameSlider(
            visible: state.gravityBarVisible,
            variable: state.gravity,
            onChanged: (v) {
              state.gravity = v;
              controller.changeGravity(v);
            },
          ),
          // ),
        ],
      ),
      Row(
        children: [
          Button(
            onPressed: () {
              state.sizeBarVisible = !state.sizeBarVisible;
            },
            icon: Icon(Icons.zoom_in),
            label: 'Particle Size',
          ),
          GameSlider(
            visible: state.sizeBarVisible,
            variable: state.particleSize,
            onChanged: (v) {
              state.particleSize = v;
              controller.changeParticleSize(v);
            },
          ),
          // ),
        ],
      ),
    ];
  }
}

class MainEntriesState extends ChangeNotifier {
  bool _gravityBarVisible = false;
  bool get gravityBarVisible => _gravityBarVisible;
  set gravityBarVisible(bool gravityBarVisible) {
    _gravityBarVisible = gravityBarVisible;
    notifyListeners();
  }

  bool _sizeBarVisible = false;
  bool get sizeBarVisible => _sizeBarVisible;
  set sizeBarVisible(bool value) {
    _sizeBarVisible = value;
    notifyListeners();
  }

  double _gravity = (initialGravity - minGravity) / (maxGravity - minGravity);
  double get gravity => _gravity;
  set gravity(double value) {
    _gravity = value;
    notifyListeners();
  }

  double _particleSize =
      (initialParticleSize - smallestParticleSize) /
      (largestParticleSize - smallestParticleSize);
  double get particleSize => _particleSize;
  set particleSize(double value) {
    _particleSize = value;
    notifyListeners();
  }

  Icon _playPauseIcon = Icon(Icons.pause);
  Icon get playPauseIcon => _playPauseIcon;
  set playPauseIcon(Icon value) {
    _playPauseIcon = value;
    notifyListeners();
  }

  String _playPauseLabel = 'Pause';
  String get playPauseLabel => _playPauseLabel;
  set playPauseLabel(String value) {
    _playPauseLabel = value;
    notifyListeners();
  }

  bool _paused = false;
  bool get paused => _paused;
  set paused(bool value) {
    _paused = value;
    notifyListeners();
  }
}
