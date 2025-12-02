import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_manager.dart';
import '../widgets/iso_map_widget.dart';
import 'boss_arena.dart';

class WorldScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gm = Provider.of<GameManager>(context);
    return Scaffold(
      appBar: AppBar(title: Text('HavenRise — World')),
      body: Column(
        children: [
          Container(height: 80, color: Colors.grey[900], child: _topBar(gm)),
          Expanded(child: IsoMapWidget()),
          Container(height: 80, color: Colors.grey[850], child: _bottomBar(context, gm)),
        ],
      ),
    );
  }

  Widget _topBar(GameManager gm) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(children: [
        Text('Pop: ${gm.population}', style: TextStyle(fontSize: 16)),
        SizedBox(width: 12),
        Text('Hap: ${(gm.happiness*100).toInt()}%'),
        Spacer(),
        Text('Wood: ${gm.wood}  Stone: ${gm.stone}  Food: ${gm.food}'),
      ]),
    );
  }

  Widget _bottomBar(BuildContext ctx, GameManager gm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(onPressed: () => gm.placeBuildingAt(0,0, BuildingType.hut), child: Text('Place Hütte')),
        SizedBox(width: 12),
        ElevatedButton(onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => BossArena())), child: Text('Boss-Arena (Demo)')),
        SizedBox(width: 12),
        ElevatedButton(onPressed: () => gm.saveGame(), child: Text('Save')),
      ],
    );
  }
}
