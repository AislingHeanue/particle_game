import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'expandable_menu.dart';

class PopoutAnimation extends StatelessWidget {
  const PopoutAnimation({
    super.key,
    required this.offset,
    required this.direction,
    required this.child,
  });

  final double offset;
  final Widget child;
  final Axis direction;

  Animation<Offset> popout(
    AnimationController animationController,
    double offset,
  ) {
    return Tween<Offset>(
      begin: direction == Axis.vertical
          ? Offset(0, -offset - 1)
          : Offset(-offset - 1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    ExpandableMenuState state = context.watch<ExpandableMenuState>();
    return SlideTransition(
      position: popout(state.animationController, offset),
      child: Visibility(visible: state.entriesVisible, child: child),
    );
  }
}
