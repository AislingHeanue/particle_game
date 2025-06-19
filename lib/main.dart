import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:particle_game/src/widgets/game_app.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  WakelockPlus.enable();

  runApp(GameApp());
}
