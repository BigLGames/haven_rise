import 'package:flutter/material.dart';
import 'dart:math';

// Simplified 1v1 boss arena built with Flutter widgets and Canvas for demo.
class BossArena extends StatefulWidget {
  @override
  _BossArenaState createState() => _BossArenaState();
}

class _BossArenaState extends State<BossArena> with SingleTickerProviderStateMixin {
  double playerX = 100, playerY = 200;
  double bossX = 300, bossY = 200;
  double playerHP = 150, bossHP = 400;
  double ult = 0.0;
  late Ticker _ticker;
  double _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((dur) {
      final dt = dur.inMilliseconds / 1000.0;
      _elapsed += dt;
      // simple AI: boss moves toward player slowly
      setState(() {
        final dx = playerX - bossX;
        final dy = playerY - bossY;
        final dist = sqrt(dx*dx + dy*dy);
        if (dist > 60) {
          bossX += dx / dist * 30 * dt;
          bossY += dy / dist * 30 * dt;
        }
        // boss periodic attack
        if (_elapsed > 1.2) {
          if (sqrt((playerX-bossX)*(playerX-bossX) + (playerY-bossY)*(playerY-bossY)) < 70) {
            playerHP -= 10;
          }
          _elapsed = 0;
        }
        // player passive regen small ult
        ult = (ult + dt * 0.02).clamp(0.0, 1.0);
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _movePlayer(Offset delta) {
    setState(() {
      playerX = (playerX + delta.dx).clamp(20.0, 380.0);
      playerY = (playerY + delta.dy).clamp(80.0, 520.0);
    });
  }

  void _attack() {
    if (sqrt((playerX-bossX)*(playerX-bossX) + (playerY-bossY)*(playerY-bossY)) < 70) {
      setState(() {
        bossHP -= 18;
        ult = (ult + 0.08).clamp(0.0, 1.0);
      });
    }
  }

  void _dodge() {
    setState(() {
      playerX += 30;
      ult = (ult + 0.04).clamp(0.0, 1.0);
    });
  }

  void _ultimate() {
    if (ult >= 1.0) {
      setState(() {
        bossHP -= 120;
        ult = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: Text('Boss Arena')),
      body: Stack(
        children: [
          CustomPaint(
            size: Size(w, h),
            painter: _ArenaPainter(playerX, playerY, bossX, bossY),
          ),
          Positioned(top: 16, left: 16, child: _statusPanel()),
          Positioned(bottom: 20, left: 16, child: _controls()),
        ],
      ),
    );
  }

  Widget _statusPanel() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Player HP: ${playerHP.toInt()}'),
      Text('Boss HP: ${bossHP.toInt()}'),
      SizedBox(height:8),
      LinearProgressIndicator(value: ult, minHeight: 8),
    ],
  );

  Widget _controls() {
    return Row(
      children: [
        GestureDetector(
          onPanUpdate: (d) => _movePlayer(d.delta),
          child: Container(width: 140, height: 140, color: Colors.grey[800], child: Center(child: Text('Joystick'))),
        ),
        SizedBox(width: 12),
        Column(
          children: [
            ElevatedButton(onPressed: _attack, child: Text('Attack')),
            SizedBox(height:8),
            ElevatedButton(onPressed: _dodge, child: Text('Dodge')),
            SizedBox(height:8),
            ElevatedButton(onPressed: _ultimate, child: Text('ULT')),
          ],
        )
      ],
    );
  }
}

class _ArenaPainter extends CustomPainter {
  final double px, py, bx, by;
  _ArenaPainter(this.px, this.py, this.bx, this.by);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.brown.shade700;
    canvas.drawRect(Rect.fromLTWH(0,0,size.width,size.height), paint);
    final pPaint = Paint()..color = Colors.blueAccent;
    final bPaint = Paint()..color = Colors.redAccent;
    canvas.drawCircle(Offset(px, py), 18, pPaint);
    canvas.drawCircle(Offset(bx, by), 28, bPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
