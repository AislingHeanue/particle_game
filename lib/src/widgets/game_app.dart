import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/components.dart';
import '../core/particle_game.dart';
import './entries/main.dart';
import './expandable_menu.dart';

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => GameAppState();
}

class GameAppState extends State<GameApp> {
  final ParticleGame _game = ParticleGame();
  Controller get controller => _game.controller;

  @override
  Widget build(BuildContext context) {
    MainEntriesState mainMenuEntriesState = MainEntriesState();
    return Provider(
      create: (context) => this,
      child: ChangeNotifierProvider(
        create: (context) => mainMenuEntriesState,
        builder: (context, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: GameWidget(game: _game),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            floatingActionButton: ExpandableMenu(
              child: MainEntries(controller: controller),
              direction: Axis.vertical,
              icon: Icon(Icons.settings),
              spin: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
