import 'package:flutter/material.dart';

class GameInfo {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final String tag;

  const GameInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tag,
  });
}

class GameRegistry {
  static const List<GameInfo> games = [
    GameInfo(
      id: 'snake',
      title: 'Snake',
      description: 'Classic retro snake. Eat food, grow longer, avoid walls!',
      icon: Icons.pest_control_rounded,
      primaryColor: Color(0xFF00E676),
      secondaryColor: Color(0xFF00B0FF),
      tag: 'RETRO CANVAS',
    ),
    GameInfo(
      id: 'tictactoe',
      title: 'Tic-Tac-Toe',
      description: 'Hand-drawn paper notebook style game vs friend or AI.',
      icon: Icons.grid_3x3_rounded,
      primaryColor: Color(0xFF2979FF),
      secondaryColor: Color(0xFFFF1744),
      tag: 'PAPER EDITION',
    ),
    GameInfo(
      id: 'brick_breaker',
      title: 'Brick Breaker',
      description: 'Smash all glowing neon bricks with paddle physics & combos!',
      icon: Icons.view_comfy_alt_rounded,
      primaryColor: Color(0xFFFF9100),
      secondaryColor: Color(0xFFFFD600),
      tag: 'ARCADE PHYSICS',
    ),
    GameInfo(
      id: 'space_shooter',
      title: 'Space Shooter',
      description: 'Defend space against alien waves, asteroids & boss lasers!',
      icon: Icons.rocket_launch_rounded,
      primaryColor: Color(0xFFD500F9),
      secondaryColor: Color(0xFF651FFF),
      tag: 'ACTION GALACTIC',
    ),
  ];

  static GameInfo getById(String id) {
    return games.firstWhere(
      (g) => g.id == id,
      orElse: () => games.first,
    );
  }
}
