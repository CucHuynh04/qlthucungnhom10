// lib/sound_helper.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// Helper class để phát âm thanh feedback nhẹ cho các button
class SoundHelper {
  static bool _initialized = false;
  static bool _useAssetSounds = true;

  /// Phát âm thanh click nhẹ như Facebook
  static Future<void> playClickSound() async {
    try {
      if (kIsWeb || !_useAssetSounds || !_initialized) {
        // Web hoặc không có assets - dùng system sound
        SystemSound.play(SystemSoundType.click);
        return;
      }

      // Desktop/Mobile - thử dùng audio player
      final player = AudioPlayer();
      try {
        await player.play(AssetSource('sounds/click.mp3'));
      } catch (e) {
        SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Phát âm thanh khi thêm thành công
  static Future<void> playSuccessSound() async {
    try {
      if (kIsWeb || !_useAssetSounds || !_initialized) {
        SystemSound.play(SystemSoundType.click);
        return;
      }

      final player = AudioPlayer();
      try {
        await player.play(AssetSource('sounds/success.mp3'));
      } catch (e) {
        SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Phát âm thanh khi có lỗi
  static Future<void> playErrorSound() async {
    try {
      if (kIsWeb || !_useAssetSounds || !_initialized) {
        SystemSound.play(SystemSoundType.alert);
        return;
      }

      final player = AudioPlayer();
      try {
        await player.play(AssetSource('sounds/error.mp3'));
      } catch (e) {
        SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  /// Dispose khi không dùng nữa
  static void dispose() {
    // No-op for web
  }
}






