import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../particle_game.dart';

class GlobalState extends ChangeNotifier {
  int selectedIndex = 0;

  void settingsScreen() {
    selectedIndex = 1;
    notifyListeners();
  }

  void gameScreen() {
    selectedIndex = 0;
    notifyListeners();
  }
}

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => GameAppState();
}

class GameAppState extends State<GameApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GlobalState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        home: PageSwitcher(),
      ),
    );
  }
}

class PageSwitcher extends StatelessWidget {
  const PageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    var globalState = context.watch<GlobalState>();
    final Widget page;
    switch (globalState.selectedIndex) {
      case 0:
        page = GamePage();
      case 1:
        page = SettingsPage();
      default:
        throw UnimplementedError('too many buttons!');
    }
    return Scaffold(body: page);
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    var globalState = context.watch<GlobalState>();
    final game = ParticleGame();
    return Stack(
      children: [
        GameWidget(
          game: game,
          overlayBuilderMap: {
            Screen.settings.name: (context, game) => Card(
              child: Padding(padding: EdgeInsets.all(16.0), child: Text('hi')),
            ),
          },
        ),
        SafeArea(
          child: IconButton(
            onPressed: () {
              globalState.settingsScreen();
            },
            icon: Icon(Icons.settings),
          ),
        ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var globalState = context.watch<GlobalState>();
    return Center(
      child: Column(
        children: [
          Card(
            child: Padding(padding: EdgeInsets.all(16.0), child: Text("HELLO")),
          ),
          ElevatedButton(
            onPressed: () {
              globalState.gameScreen();
            },
            child: Text("Go back to the game"),
          ),
        ],
      ),
    );
  }
}
