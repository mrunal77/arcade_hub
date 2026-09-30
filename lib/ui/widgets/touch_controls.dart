import 'package:flutter/material.dart';
import '../../core/game_engine.dart';

class TouchControlsOverlay extends StatelessWidget {
  final ValueChanged<GameInput> onInput;
  final bool showActionButton;
  final String actionLabel;
  final Color themeColor;

  const TouchControlsOverlay({
    super.key,
    required this.onInput,
    this.showActionButton = true,
    this.actionLabel = 'ACTION',
    this.themeColor = const Color(0xFF00E676),
  });

  Widget _dpadBtn(IconData icon, GameDirection dir) {
    return GestureDetector(
      onTapDown: (_) => onInput(GameInput(direction: dir)),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: themeColor.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: themeColor.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // D-Pad
          SizedBox(
            width: 155,
            height: 155,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(top: 0, child: _dpadBtn(Icons.keyboard_arrow_up_rounded, GameDirection.up)),
                Positioned(bottom: 0, child: _dpadBtn(Icons.keyboard_arrow_down_rounded, GameDirection.down)),
                Positioned(left: 0, child: _dpadBtn(Icons.keyboard_arrow_left_rounded, GameDirection.left)),
                Positioned(right: 0, child: _dpadBtn(Icons.keyboard_arrow_right_rounded, GameDirection.right)),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                    border: Border.all(color: themeColor.withValues(alpha: 0.4)),
                  ),
                ),
              ],
            ),
          ),
          if (showActionButton)
            GestureDetector(
              onTapDown: (_) => onInput(
                const GameInput(action: GameAction.actionA),
              ),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeColor,
                      themeColor.withValues(alpha: 0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
