import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'settings_manager.dart';

enum SoundEffect {
  move,
  tap,
  score,
  powerUp,
  laser,
  hit,
  explosion,
  win,
  gameOver,
}

class AudioManager {
  static AudioManager? _instance;
  static AudioManager get instance => _instance ??= AudioManager._();

  AudioManager._();

  bool get soundEnabled => SettingsManager.instance.soundEnabled;

  /// Play sound effect by name
  void play(SoundEffect effect) {
    if (!soundEnabled) return;

    try {
      switch (effect) {
        case SoundEffect.tap:
        case SoundEffect.move:
          SystemSound.play(SystemSoundType.click);
          HapticFeedback.lightImpact();
          break;
        case SoundEffect.score:
        case SoundEffect.powerUp:
          HapticFeedback.mediumImpact();
          break;
        case SoundEffect.laser:
        case SoundEffect.hit:
          HapticFeedback.lightImpact();
          break;
        case SoundEffect.explosion:
        case SoundEffect.gameOver:
          HapticFeedback.heavyImpact();
          break;
        case SoundEffect.win:
          HapticFeedback.vibrate();
          break;
      }
    } catch (e) {
      debugPrint('Audio effect failed: $e');
    }
  }

  /// Synthesize WAV PCM bytes for 8-bit retro sound effects if audio player is connected
  static Uint8List generateToneWav({
    required double frequency,
    required double durationSeconds,
    double sampleRate = 22050,
    String waveType = 'square', // 'square', 'sine', 'sawtooth', 'noise'
  }) {
    final numSamples = (sampleRate * durationSeconds).toInt();
    final dataSize = numSamples * 2;
    final fileSize = 44 + dataSize;

    final bytes = ByteData(fileSize);

    // RIFF header
    bytes.setUint8(0, 0x52); // R
    bytes.setUint8(1, 0x49); // I
    bytes.setUint8(2, 0x46); // F
    bytes.setUint8(3, 0x46); // F
    bytes.setUint32(4, fileSize - 8, Endian.little);
    bytes.setUint8(8, 0x57); // W
    bytes.setUint8(9, 0x41); // A
    bytes.setUint8(10, 0x56); // V
    bytes.setUint8(11, 0x45); // E

    // fmt subchunk
    bytes.setUint8(12, 0x66); // f
    bytes.setUint8(13, 0x6D); // m
    bytes.setUint8(14, 0x74); // t
    bytes.setUint8(15, 0x20); // ' '
    bytes.setUint32(16, 16, Endian.little); // Subchunk1Size
    bytes.setUint16(20, 1, Endian.little); // AudioFormat (PCM)
    bytes.setUint16(22, 1, Endian.little); // NumChannels (Mono)
    bytes.setUint32(24, sampleRate.toInt(), Endian.little);
    bytes.setUint32(28, (sampleRate * 2).toInt(), Endian.little); // ByteRate
    bytes.setUint16(32, 2, Endian.little); // BlockAlign
    bytes.setUint16(34, 16, Endian.little); // BitsPerSample

    // data subchunk
    bytes.setUint8(36, 0x64); // d
    bytes.setUint8(37, 0x61); // a
    bytes.setUint8(38, 0x74); // t
    bytes.setUint8(39, 0x61); // a
    bytes.setUint32(40, dataSize, Endian.little);

    final rng = Random();
    final period = sampleRate / frequency;

    for (int i = 0; i < numSamples; i++) {
      double sample = 0.0;
      final t = i / numSamples;
      final envelope = (1.0 - t).clamp(0.0, 1.0);

      if (waveType == 'square') {
        sample = (i % period < period / 2) ? 0.6 : -0.6;
      } else if (waveType == 'sine') {
        sample = sin(2 * pi * frequency * i / sampleRate);
      } else if (waveType == 'sawtooth') {
        sample = 2.0 * ((i % period) / period) - 1.0;
      } else if (waveType == 'noise') {
        sample = (rng.nextDouble() * 2.0 - 1.0);
      }

      sample *= envelope;
      final pcmValue = (sample * 32767).clamp(-32768, 32767).toInt();
      bytes.setInt16(44 + i * 2, pcmValue, Endian.little);
    }

    return bytes.buffer.asUint8List();
  }
}
