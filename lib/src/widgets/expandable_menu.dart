import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './has_entries.dart';
import './popout_animation.dart';
import 'button.dart';

class ExpandableMenu extends StatefulWidget {
  const ExpandableMenu({
    super.key,
    required this.direction,
    required this.child,
    required this.spin,
    required this.icon,
    bool? normalButton,
    String? label,
    this.parent,
  }) : normalButton = normalButton ?? false,
       label = label ?? '';

  final Axis direction;
  final HasEntries child;
  final double spin;
  final Icon icon;
  final bool normalButton;
  final String label;
  final ExpandableMenuState? parent;

  @override
  State<ExpandableMenu> createState() => ExpandableMenuState();
}

class ExpandableMenuState extends State<ExpandableMenu>
    with SingleTickerProviderStateMixin {
  late Animation<double> _turns;
  late AnimationController animationController;
  bool _expand = false;
  Color _mainBackgroundColour = Colors.transparent;
  final Color buttonForegroundColour = Colors.grey[850]!;
  bool entriesVisible = false;
  bool menuMoving = false;

  // force showTooltips to inherit from its parent if one is set.
  bool showTooltips = false;

  void toggleTooltips() {
    setState(() {
      showTooltips = !showTooltips;
    });
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _turns = Tween<double>(begin: 0.0, end: widget.spin).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => this,
      child: Stack(
        children: [
          Transform.translate(
            offset: widget.direction == Axis.vertical
                ? Offset(0, 45)
                : widget.parent != null && widget.parent!.showTooltips
                ? Offset(164, 0)
                : Offset(48, 0),
            child: Builder(
              builder: (context) {
                return Flex(
                  direction: widget.direction,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.child
                      .entries(context)
                      .asMap()
                      .map((i, v) {
                        return MapEntry(
                          i,
                          PopoutAnimation(
                            offset: i.toDouble(),
                            direction: widget.direction,
                            child: v,
                          ),
                        );
                      })
                      .values
                      .toList(),
                );
              },
            ),
          ),
          widget.normalButton
              ? Provider(
                  create: (context) => widget.parent!,
                  child: Button(
                    label: widget.label,
                    onPressed: () {
                      setState(() {
                        _expand = !_expand;
                        if (_expand) {
                          entriesVisible = true;
                          menuMoving = true;
                          animationController.forward().then((v) {
                            setState(() {
                              menuMoving = false;
                            });
                          });
                        } else {
                          menuMoving = true;
                          animationController.reverse().then((v) {
                            setState(() {
                              menuMoving = false;
                              entriesVisible = false;
                            });
                          });
                        }
                      });
                    },
                    icon: widget.spin != 0
                        ? RotationTransition(turns: _turns, child: widget.icon)
                        : widget.icon,
                  ),
                )
              : FloatingActionButton.small(
                  onPressed: () {
                    setState(() {
                      _expand = !_expand;
                      if (_expand) {
                        _mainBackgroundColour = Colors.deepPurple[300]!;
                        entriesVisible = true;
                        menuMoving = true;
                        animationController.forward().then((v) {
                          setState(() {
                            menuMoving = false;
                          });
                        });
                      } else {
                        menuMoving = true;
                        animationController.reverse().then((v) {
                          setState(() {
                            menuMoving = false;
                            _mainBackgroundColour = Colors.transparent;
                            entriesVisible = false;
                          });
                        });
                      }
                    });
                  },
                  backgroundColor: _mainBackgroundColour,
                  foregroundColor: buttonForegroundColour,
                  focusColor: Colors.purple,
                  child: widget.spin != 0
                      ? RotationTransition(turns: _turns, child: widget.icon)
                      : widget.icon,
                ),
        ],
      ),
    );
  }
}
