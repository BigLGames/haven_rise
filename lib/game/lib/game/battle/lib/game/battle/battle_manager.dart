import 'dart:math';
import 'package:flutter/foundation.dart';
import 'unit.dart';
import 'astar.dart';

// lightweight battle manager
class BattleManager {
  final int width, height;
  Set<Point<int>> blocked = {};
  Map<String, Unit> units = {};
  double timeScale = 1.0;

  BattleManager({required this.width, required this.height});

  void addUnit(Unit u) => units[u.id] = u;
  void removeDead() => units.removeWhere((k,u) => !u.isAlive);

  void tick(double dt) {
    // movement
    units.values.where((u) => u.isAlive).forEach((u) {
      if (u.currentOrder.type == OrderType.move && u.path.isNotEmpty) {
        _moveAlong(u, dt);
      } else if (u.currentOrder.type == OrderType.attack) {
        _processAttack(u, dt);
      }
    });
    _resolveCombat(dt);
    removeDead();
  }

  void _moveAlong(Unit u, double dt) {
    if (u.path.isEmpty) return;
    final next = u.path.first;
    final tx = next.x + 0.5;
    final ty = next.y + 0.5;
    final dx = tx - u.x;
    final dy = ty - u.y;
    final dist = sqrt(dx*dx + dy*dy);
    if (dist < 0.05) { u.x = tx; u.y = ty; u.path.removeAt(0); return; }
    final move = u.speed * dt * timeScale;
    if (move >= dist) { u.x = tx; u.y = ty; u.path.removeAt(0); } else {
      u.x += dx / dist * move; u.y += dy / dist * move;
    }
  }

  void _processAttack(Unit u, double dt) {
    if (u.currentOrder.targetId == null) return;
    final t = units[u.currentOrder.targetId!];
    if (t == null || !t.isAlive) { u.currentOrder = Order(type: OrderType.idle); return; }
    final dx = t.x - u.x;
    final dy = t.y - u.y;
    final dist = sqrt(dx*dx + dy*dy);
    if (dist > u.range) {
      final start = Point<int>(u.x.floor(), u.y.floor());
      final goal = Point<int>(t.x.floor(), t.y.floor());
      u.path = aStar(start, goal, blocked, width-1, height-1);
      u.currentOrder = Order(type: OrderType.move, tx: goal.x.toDouble(), ty: goal.y.toDouble(), targetId: t.id);
    }
  }

  void _resolveCombat(double dt) {
    final us = units.values.where((u) => u.isAlive).toList();
    for (var u in us) {
      for (var v in us) {
        if (u.teamId == v.teamId) continue;
        final dx = v.x - u.x;
        final dy = v.y - u.y;
        final dist = sqrt(dx*dx + dy*dy);
        if (dist <= u.range + 0.1) {
          final damage = u.attack * dt;
          v.hp -= damage * (1.0 - (v.type == UnitType.elite ? 0.15 : 0.0));
          v.morale = (v.morale - (damage / v.maxHp) * 0.2).clamp(0.0, 1.0);
        }
      }
    }
  }

  void issueMove(String id, int tx, int ty) {
    final u = units[id];
    if (u==null) return;
    final start = Point<int>(u.x.floor(), u.y.floor());
    final goal = Point<int>(tx, ty);
    u.path = aStar(start, goal, blocked, width-1, height-1);
    u.currentOrder = Order(type: OrderType.move, tx: tx.toDouble(), ty: ty.toDouble());
  }

  void issueAttack(String id, String targetId) {
    final u = units[id];
    if (u==null) return;
    u.currentOrder = Order(type: OrderType.attack, targetId: targetId);
  }
}
