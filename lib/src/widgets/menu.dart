import 'package:flutter/material.dart';
import 'package:particle_game/src/components/controller.dart';
import 'package:provider/provider.dart';

import 'game_app.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => MenuState();
}

class MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  late Animation<double> _turns;
  late AnimationController _animationController;
  bool _expand = false;
  bool _entriesVisible = false;
  Color _mainBackgroundColour = Colors.transparent;
  bool _gravityBarVisible = false;
  double _gravity = 1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _turns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Controller controller = context.read<GameAppState>().controller;
    return Provider(
      create: (context) => this,
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(0, 45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MenuEntry(
                  offset: 0,
                  child: MenuEntryButton(
                    onPressed: controller.spawnParticles,
                    icon: Icon(Icons.settings),
                  ),
                ),
                MenuEntry(
                  offset: 1,
                  child: MenuEntryButton(
                    onPressed: controller.reset,
                    icon: Icon(Icons.settings),
                  ),
                ),
                MenuEntry(
                  offset: 2,
                  child: Row(
                    children: [
                      MenuEntryButton(
                        onPressed: () {
                          setState(() {
                            _gravityBarVisible = !_gravityBarVisible;
                          });
                        },
                        icon: Icon(Icons.settings),
                      ),
                      Visibility(
                        visible: _gravityBarVisible,
                        // child: SliderTheme(
                        // data: SliderThemeData(trackShape: RoundedRectSliderTrackShape()),
                        child: SizedBox(
                          width: 250,
                          height: 40,
                          child: Slider(
                            value: _gravity,
                            onChanged: (v) {
                              setState(() {
                                _gravity = v;
                              });
                              controller.changeGravity(v);
                            },
                          ),
                        ),
                      ),
                      // ),
                    ],
                  ),
                ),
                MenuEntry(
                  offset: 3,
                  child: MenuEntryButton(
                    onPressed: null,
                    icon: Icon(Icons.settings),
                  ),
                ),
              ],
            ),
          ),
          FloatingActionButton.small(
            onPressed: () {
              setState(() {
                _expand = !_expand;
                if (_expand) {
                  _animationController.forward();
                  _mainBackgroundColour = Colors.deepPurple[300]!;
                  _entriesVisible = true;
                } else {
                  _animationController.reverse().then((v) {
                    setState(() {
                      _mainBackgroundColour = Colors.transparent;
                      _entriesVisible = false;
                    });
                    _gravityBarVisible = false;
                  });
                }
              });
              // globalState.settingsScreen();
            },
            backgroundColor: _mainBackgroundColour,
            foregroundColor: Colors.grey[850],
            focusColor: Colors.purple,
            // mini: true,
            child: RotationTransition(
              turns: _turns,
              child: Icon(Icons.settings),
            ),

            // : ThemeData.from(colorScheme: ColorScheme.dark(primary: Colors.black),
          ),
        ],
      ),
    );
  }
}

class MenuEntry extends StatelessWidget {
  const MenuEntry({super.key, required double offset, required Widget child})
    : _offset = offset,
      _child = child;

  final double _offset;
  final Widget _child;

  Animation<Offset> popout(
    AnimationController animationController,
    double offset,
  ) {
    return Tween<Offset>(
      begin: Offset(0, -offset - 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    MenuState state = context.watch<MenuState>();
    return SlideTransition(
      position: popout(state._animationController, _offset),
      child: Visibility(visible: state._entriesVisible, child: _child),
    );
  }
}

class MenuEntryButton extends StatelessWidget {
  const MenuEntryButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: EdgeInsetsGeometry.only(top: 7.0),
      decoration: const ShapeDecoration(
        shape: CircleBorder(),
        color: Colors.white,
      ),

      child: IconButton(onPressed: onPressed, icon: icon),
    );
  }
}
