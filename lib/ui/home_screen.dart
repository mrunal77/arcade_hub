import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/game_registry.dart';
import '../core/settings_manager.dart';
import 'game_screen.dart';
import 'high_scores_screen.dart';
import 'settings_screen.dart';
import 'widgets/arcade_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isWide = media.size.width > 680;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Arcade Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00E676).withValues(alpha: 0.6),
                            ),
                          ),
                          child: const Icon(
                            Icons.sports_esports_rounded,
                            color: Color(0xFF00E676),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ARCADE HUB',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'RETRO MULTI-GAME PLATFORM',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00E676),
                                  letterSpacing: 1.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: SettingsManager.instance.soundEnabledNotifier,
                        builder: (context, soundEnabled, _) {
                          return IconButton(
                            icon: Icon(
                              soundEnabled
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              color: soundEnabled
                                  ? const Color(0xFF00E676)
                                  : Colors.white38,
                            ),
                            onPressed: () {
                              SettingsManager.instance.toggleSound();
                              AudioManager.instance.play(SoundEffect.tap);
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_events_rounded, color: Colors.amber),
                        onPressed: () {
                          AudioManager.instance.play(SoundEffect.tap);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HighScoresScreen(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_rounded, color: Colors.white70),
                        onPressed: () {
                          AudioManager.instance.play(SoundEffect.tap);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Game Selection Grid / Carousel
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 2 : 1,
                    childAspectRatio: isWide ? 1.6 : 1.4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: GameRegistry.games.length,
                  itemBuilder: (context, index) {
                    final gameInfo = GameRegistry.games[index];
                    return ArcadeCard(
                      gameInfo: gameInfo,
                      onTap: () {
                        AudioManager.instance.play(SoundEffect.tap);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameScreen(gameId: gameInfo.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
