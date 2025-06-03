import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:particle_game/src/widgets/game_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(GameApp());
}

