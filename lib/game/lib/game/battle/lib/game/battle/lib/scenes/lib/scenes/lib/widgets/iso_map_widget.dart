import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_manager.dart';

class IsoMapWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gm = Provider.of<GameManager>(context);
    if (gm.tiles.isEmpty) return Center(child: Text('No map'));
    // render a small chunk as grid for MVP
    final tiles = gm.tiles;
    final minX = tiles.map((t)=>t.x).reduce((a,b)=>a<b?a:b);
    final maxX = tiles.map((t)=>t.x).reduce((a,b)=>a>b?a:b);
    final minY = tiles.map((t)=>t.y).reduce((a,b)=>a<b?a:b);
    final maxY = tiles.map((t)=>t.y).reduce((a,b)=>a>b?a:b);
    final rows = maxY - minY + 1;
    final cols = maxX - minX + 1;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: List.generate(rows, (ry) {
          final y = minY + ry;
          return Row(
            children: List.generate(cols, (cx) {
              final x = minX + cx;
              final t = tiles.firstWhere((tt)=>tt.x==x && tt.y==y, orElse: ()=>Tile(x:x,y:y));
              return GestureDetector(
                onTap: () {
                  // quick place preview for testing
                },
                child: _tileWidget(t),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _tileWidget(Tile t) {
    Color c;
    switch(t.terrain) {
      case 'water': c = Colors.blue.shade300; break;
      case 'beach': c = Colors.yellow.shade200; break;
      case 'rock': c = Colors.grey; break;
      case 'forest': c = Colors.green.shade700; break;
      default: c = Colors.green.shade400; break;
    }
    Widget child = Container(width: 48, height: 48, color: c, margin: EdgeInsets.all(1), child: Center());
    if (t.building != null) {
      child = Stack(children: [
        child,
        Center(child: Icon(t.building==BuildingType.hut?Icons.cottage:Icons.house, size: 18, color: Colors.brown)),
      ]);
    }
    return child;
  }
}
