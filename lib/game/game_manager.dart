// Game core: population, happiness, unlocks, basic placing and tick loop
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Biome { forest, mountain, sea }
enum BuildingType { hut, house, market, church, bar, villa, barracks }

class Tile {
  int x, y;
  String terrain;
  BuildingType? building;
  int level;
  Tile({required this.x, required this.y, this.terrain='grass', this.building, this.level=1});
  Map toJson() => {'x':x,'y':y,'terrain':terrain,'building':building?.index,'level':level};
  factory Tile.fromJson(Map m) => Tile(x:m['x'], y:m['y'], terrain:m['terrain'], building: m['building']==null?null: BuildingType.values[m['building']], level: m['level'] ?? 1);
}

class GameManager extends ChangeNotifier {
  Biome currentBiome = Biome.forest;
  int seed = 0;
  List<Tile> tiles = [];
  int mapRadius = 8;

  int population = 10;
  double happiness = 0.8;
  int wood = 200, stone = 150, food = 300;
  int level = 1;
  int maxPopulation = 25000000;

  Map<String,bool> unlockedBuildings = {};
  Map<String,bool> unlockedUnits = {};
  Random? _rand;
  Timer? _tickTimer;

  GameManager() {
    newGame(Biome.forest);
    _tickTimer = Timer.periodic(Duration(seconds:1), (_) => tick());
  }

  void newGame(Biome b) {
    currentBiome = b;
    seed = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    _rand = Random(seed);
    tiles.clear();
    mapRadius = 8;
    _generateTiles();
    population = 10;
    happiness = 0.8;
    wood = (b==Biome.forest)? 300 : 150;
    stone = (b==Biome.mountain)? 300 : 120;
    food = 200;
    unlockedBuildings = {};
    unlockedUnits = {};
    checkUnlocks();
    notifyListeners();
  }

  void _generateTiles() {
    for (int x=-mapRadius; x<=mapRadius; x++) {
      for (int y=-mapRadius; y<=mapRadius; y++) {
        tiles.add(Tile(x: x, y: y, terrain: _pickTerrain(x,y)));
      }
    }
  }

  String _pickTerrain(int x, int y) {
    int n = (_rand!.nextInt(100) + x.abs() + y.abs()) % 100;
    if (currentBiome == Biome.sea) {
      if (n < 30) return 'water';
      if (n < 60) return 'beach';
      return 'grass';
    } else if (currentBiome == Biome.mountain) {
      if (n < 30) return 'rock';
      if (n < 60) return 'grass';
      return 'forest';
    } else {
      if (n < 40) return 'forest';
      return 'grass';
    }
  }

  void tick() {
    final growth = max(0, (population * 0.005 * happiness).toInt());
    updatePopulation(population + growth);

    int prodWood = (currentBiome==Biome.forest)? 5 : 1;
    int prodStone = (currentBiome==Biome.mountain)? 3 : 1;
    int prodFood = 5;
    wood += prodWood;
    stone += prodStone;
    food += prodFood - (population ~/ 50);

    double bonus = 0.0;
    if (unlockedBuildings['market'] == true) bonus += 0.001;
    if (unlockedBuildings['church'] == true) bonus += 0.002;
    if (unlockedBuildings['bar'] == true) bonus += 0.0015;
    happiness = (happiness + bonus).clamp(0.0, 1.0);

    checkUnlocks();
    notifyListeners();
  }

  void updatePopulation(int p) {
    population = p.clamp(0, maxPopulation);
    level = max(1, (population ~/ 250000) + 1);
    checkUnlocks();
    notifyListeners();
  }

  void checkUnlocks() {
    final buildingUnlocks = {
      500: 'market',
      1000: 'church',
      2500: 'bar',
      5000: 'villa',
      20000: 'park',
      50000: 'butcher',
      100000: 'smith',
      500000: 'theater',
      1000000: 'university',
      5000000: 'harbor',
      10000000: 'bank',
      20000000: 'palace'
    };
    buildingUnlocks.forEach((pop, key) {
      if (population >= pop && unlockedBuildings[key] != true) unlockedBuildings[key] = true;
    });

    final unitUnlocks = {
      15: 'barracks',
      25: 'lancers',
      35: 'cavalry',
      45: 'elite',
      55: 'archers',
      65: 'siege',
      75: 'knights',
      85: 'artillery',
      95: 'eliteCav',
      100: 'fortress'
    };
    unitUnlocks.forEach((lvl, key) {
      if (level >= lvl && unlockedUnits[key] != true) unlockedUnits[key] = true;
    });
  }

  bool placeBuildingAt(int gx, int gy, BuildingType b) {
    final t = tiles.firstWhere((tt)=>tt.x==gx && tt.y==gy, orElse: ()=>Tile(x:gx,y:gy));
    if (t.building != null) return false;
    final costWood = 100;
    final costStone = 50;
    if (wood < costWood || stone < costStone) return false;
    wood -= costWood; stone -= costStone;
    t.building = b;
    notifyListeners();
    return true;
  }

  Future<void> saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'population': population,
      'happiness': happiness,
      'wood': wood,
      'stone': stone,
      'food': food
    };
    prefs.setString('save', data.toString());
  }

  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }
}
