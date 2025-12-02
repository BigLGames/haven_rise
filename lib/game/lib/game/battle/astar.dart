// small A* pathfinding on integer grid
import 'dart:collection';
import 'dart:math';

double _heuristic(Point<int> a, Point<int> b) => (a.x - b.x).abs() + (a.y - b.y).abs();

Iterable<Point<int>> _neighbors(int x,int y,int maxX,int maxY) sync* {
  final dirs = [Point(1,0), Point(-1,0), Point(0,1), Point(0,-1)];
  for (var d in dirs) {
    int nx = x + d.x, ny = y + d.y;
    if (nx>=0 && ny>=0 && nx<=maxX && ny<=maxY) yield Point(nx,ny);
  }
}

List<Point<int>> aStar(Point<int> start, Point<int> goal, Set<Point<int>> blocked, int maxX, int maxY) {
  var open = PriorityQueue<MapEntry<Point<int>, double>>((a,b) => a.value.compareTo(b.value));
  var g = <Point<int>, double>{};
  var parent = <Point<int>, Point<int>>{};
  g[start] = 0;
  open.add(MapEntry(start, _heuristic(start,goal)));
  while(open.isNotEmpty) {
    final cur = open.removeFirst().key;
    if (cur == goal) {
      var path = <Point<int>>[];
      var p = cur;
      while(p != start) {
        path.insert(0, p);
        p = parent[p]!;
      }
      return path;
    }
    for (var n in _neighbors(cur.x, cur.y, maxX, maxY)) {
      if (blocked.contains(n)) continue;
      double tentative = (g[cur] ?? double.infinity) + 1;
      if (tentative < (g[n] ?? double.infinity)) {
        g[n] = tentative;
        parent[n] = cur;
        open.add(MapEntry(n, tentative + _heuristic(n,goal)));
      }
    }
  }
  return [];
}
