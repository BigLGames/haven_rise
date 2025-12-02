// simple unit model for battles
import 'dart:math';

enum UnitType { infantry, lancer, cavalry, archer, siege, elite, dragon }
enum OrderType { idle, move, attack, hold, patrol }

class Order {
  OrderType type;
  double tx, ty;
  String? targetId;
  Order({this.type = OrderType.idle, this.tx = 0, this.ty = 0, this.targetId});
}

class Unit {
  String id;
  UnitType type;
  double x, y;
  double hp, maxHp;
  double attack;
  double range;
  double speed;
  double morale;
  int teamId;
  Order currentOrder = Order();
  List<Point<int>> path = [];

  Unit({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.teamId,
    double? hp, double? attack, double? range, double? speed, double? morale
  })  : maxHp = hp ?? _defaultHp(type),
       hp = hp ?? _defaultHp(type),
       attack = attack ?? _defaultAttack(type),
       range = range ?? _defaultRange(type),
       speed = speed ?? _defaultSpeed(type),
       morale = morale ?? 1.0;

  bool get isAlive => hp > 0;

  static double _defaultHp(UnitType t) {
    switch(t) {
      case UnitType.infantry: return 100;
      case UnitType.lancer: return 120;
      case UnitType.cavalry: return 140;
      case UnitType.archer: return 80;
      case UnitType.siege: return 200;
      case UnitType.elite: return 180;
      case UnitType.dragon: return 500;
    }
  }
  static double _defaultAttack(UnitType t) {
    switch(t) {
      case UnitType.infantry: return 12;
      case UnitType.lancer: return 18;
      case UnitType.cavalry: return 22;
      case UnitType.archer: return 10;
      case UnitType.siege: return 35;
      case UnitType.elite: return 30;
      case UnitType.dragon: return 80;
    }
  }
  static double _defaultRange(UnitType t) {
    switch(t) {
      case UnitType.archer: return 4.0;
      case UnitType.siege: return 6.0;
      case UnitType.dragon: return 2.5;
      default: return 1.3;
    }
  }
  static double _defaultSpeed(UnitType t) {
    switch(t) {
      case UnitType.cavalry: return 3.5;
      case UnitType.lancer: return 3.0;
      case UnitType.dragon: return 4.0;
      case UnitType.siege: return 1.2;
      default: return 2.0;
    }
  }
}
