import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game/game_manager.dart';
import 'scenes/world_scene.dart';

void main() {
  runApp(HavenRiseApp());
}

class HavenRiseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameManager(),
      child: MaterialApp(
        title: 'HavenRise',
        theme: ThemeData.dark(),
        home: WorldScene(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
