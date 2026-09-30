import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/settings_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161722),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader('AUDIO & HAPTICS'),
            ValueListenableBuilder<bool>(
              valueListenable: SettingsManager.instance.soundEnabledNotifier,
              builder: (context, soundEnabled, _) {
                return _buildSwitchTile(
                  title: 'Sound Effects & Feedback',
                  subtitle: 'Enable 8-bit retro sounds and haptic vibrations',
                  icon: soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  value: soundEnabled,
                  onChanged: (val) {
                    SettingsManager.instance.setSoundEnabled(val);
                    if (val) AudioManager.instance.play(SoundEffect.tap);
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('CONTROLS & DISPLAY'),
            ValueListenableBuilder<bool>(
              valueListenable: SettingsManager.instance.showTouchControlsNotifier,
              builder: (context, showTouch, _) {
                return _buildSwitchTile(
                  title: 'Virtual Touch Controls',
                  subtitle: 'Show on-screen D-Pad and Action buttons',
                  icon: Icons.gamepad_rounded,
                  value: showTouch,
                  onChanged: (val) {
                    SettingsManager.instance.setShowTouchControls(val);
                    AudioManager.instance.play(SoundEffect.tap);
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('CONTROLS GUIDE'),
            _buildInfoCard(
              title: 'Keyboard Controls',
              content: '• Arrow Keys / WASD: Movement & Navigation\n'
                  '• Spacebar: Action / Start / Launch Ball / Shoot Laser\n'
                  '• P / ESC: Pause / Resume Game',
              icon: Icons.keyboard_rounded,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: 'Touch Controls',
              content: '• Swipe or On-screen D-Pad for Snake movement\n'
                  '• Drag Paddle / Ship to move in Brick Breaker & Space Shooter\n'
                  '• Tap cell directly in Tic-Tac-Toe',
              icon: Icons.touch_app_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF00E676),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: const Color(0xFF1E1E2C),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        activeTrackColor: const Color(0xFF00E676),
        secondary: Icon(icon, color: Colors.white70),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00B0FF), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
