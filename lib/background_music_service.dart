// lib/background_music_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Service quản lý nhạc nền của app
class BackgroundMusicService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  
  bool _isPlaying = false;
  bool _isEnabled = true;
  bool _hasAutoPlayed = false; // Đánh dấu đã auto play chưa
  double _volume = 0.3; // Âm lượng mặc định 30%
  int _currentTrackIndex = 0;
  bool _isInitialized = false;
  List<String> _tracks = [
    'sounds/nhacchill.m4a',
    // Thêm các file khác nếu có
  ];

  BackgroundMusicService() {
    _initPlayer();
  }

  void _initPlayer() async {
    try {
      // Lặp lại khi hết bài
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(_volume);
      
      // Nghe thay đổi trạng thái - đồng bộ _isPlaying với state thực tế của player
      _player.playerStateStream.listen((state) {
        final wasPlaying = _isPlaying;
        // Luôn lấy state từ player để đảm bảo đồng bộ
        _isPlaying = _player.playing;
        
        if (wasPlaying != _isPlaying) {
          print('Player state changed: playing=$_isPlaying, processingState=${state.processingState}');
          notifyListeners();
        }
      });
      
      _isInitialized = true;
      print('Music service initialized, enabled: $_isEnabled');
      
      // Auto load track ngay (không cần đợi user interaction để load)
      if (_isEnabled) {
        try {
          // Load track sẵn (không play) để sẵn sàng khi cần
          print('Pre-loading track...');
          if (_player.processingState == ProcessingState.idle) {
            await _player.setAsset(_tracks[_currentTrackIndex]);
            await _player.setLoopMode(LoopMode.one);
            await _player.setVolume(_volume);
            print('Track pre-loaded successfully');
          }
          
          // Auto play: desktop/mobile ngay lập tức, web sẽ được trigger từ HomePage sau user interaction
          if (!kIsWeb) {
            print('Auto loading and playing track (non-web platform)...');
            Future.delayed(const Duration(seconds: 1), () async {
              if (!_hasAutoPlayed && _isEnabled) {
                try {
                  print('Attempting to auto-play music...');
                  await _player.play();
                  await Future.delayed(const Duration(milliseconds: 200));
                  _isPlaying = _player.playing;
                  _hasAutoPlayed = true;
                  notifyListeners();
                  print('Music auto-played successfully, playing=$_isPlaying');
                } catch (e) {
                  print('Failed to auto-play music: $e');
                }
              }
            });
          } else {
            print('Web platform detected - track pre-loaded, ready to play after user interaction');
            // Trên web, track đã được load sẵn, sẽ được trigger từ HomePage sau khi user đăng nhập
            // Hoặc từ bất kỳ user interaction nào khác trong app
          }
        } catch (e) {
          print('Error pre-loading track: $e');
        }
      }
    } catch (e) {
      print('Error initializing music service: $e');
    }
  }
  
  Future<void> _loadAndPlay() async {
    if (!_isEnabled) return;
    
    // Chỉ auto play nếu chưa phát lần nào
    if (_hasAutoPlayed) {
      print('Already auto-played, skipping');
      return;
    }
    
    try {
      print('Loading and playing music automatically...');
      await _playCurrentTrack();
      _hasAutoPlayed = true;
    } catch (e) {
      print('Error auto playing music: $e');
      _hasAutoPlayed = true; // Mark as attempted even if failed
    }
  }

  /// Lấy danh sách track
  List<String> get tracks => _tracks;
  
  /// Âm lượng (0.0 - 1.0)
  double get volume => _volume;
  set volume(double value) {
    _volume = value.clamp(0.0, 1.0);
    _player.setVolume(_volume);
    print('Volume set to $_volume');
    notifyListeners();
  }

  /// Đang phát nhạc
  bool get isPlaying => _isPlaying;
  
  /// Đã bật nhạc nền
  bool get isEnabled => _isEnabled;

  /// Track hiện tại
  int get currentTrackIndex => _currentTrackIndex;

  /// Bật/tắt nhạc nền
  Future<void> setEnabled(bool enabled) async {
    print('setEnabled: $enabled, current playing: $_isPlaying, current enabled: $_isEnabled');
    
    if (enabled == _isEnabled) {
      print('No state change needed');
      return;
    }
    
    _isEnabled = enabled;
    
    if (enabled) {
      // Nếu bật nhạc, luôn stop và load lại từ đầu để đảm bảo state nhất quán
      print('Starting music playback...');
      try {
        // Stop player trước để reset state hoàn toàn
        if (_player.processingState != ProcessingState.idle) {
          await _player.stop();
        }
        _isPlaying = false;
        
        // Load và play track từ đầu
        await _playCurrentTrack();
        _hasAutoPlayed = true;
      } catch (e) {
        print('Error starting music: $e');
        _isPlaying = false;
      }
    } else {
      // Nếu tắt nhạc, luôn stop hoàn toàn để đảm bảo state clean
      print('Stopping music playback...');
      try {
        await _player.stop();
        _isPlaying = false;
      } catch (e) {
        print('Error stopping player: $e');
        _isPlaying = false;
      }
    }
    notifyListeners();
  }

  /// Phát nhạc
  Future<void> play() async {
    if (!_isEnabled) {
      print('Music disabled, will auto play when enabled');
      return;
    }
    
    try {
      print('Play: isPlaying=$_isPlaying, state=${_player.processingState}');
      
      // Kiểm tra trạng thái player
      if (_player.processingState == ProcessingState.idle || 
          _player.processingState == ProcessingState.loading) {
        // Chưa load gì, load track mới
        print('Loading track: ${_tracks[_currentTrackIndex]}');
        await _playCurrentTrack();
      } else if (_player.processingState == ProcessingState.ready) {
        // Đã load sẵn, chỉ cần play
        if (!_isPlaying) {
          print('Resuming playback (track already loaded)');
          await _player.play();
          // Đợi một chút để đảm bảo state được cập nhật (quan trọng cho web)
          await Future.delayed(const Duration(milliseconds: 200));
          // Kiểm tra lại state thực tế từ player
          _isPlaying = _player.playing;
          _hasAutoPlayed = true; // Đánh dấu đã phát
          notifyListeners();
          print('Music resumed successfully, playing=$_isPlaying');
        } else {
          print('Music is already playing');
        }
      } else if (_player.processingState == ProcessingState.buffering) {
        // Đang buffer, chờ một chút rồi play
        print('Player is buffering, waiting...');
        await Future.delayed(const Duration(milliseconds: 500));
        if (!_isPlaying) {
          await _player.play();
          await Future.delayed(const Duration(milliseconds: 200));
          _isPlaying = _player.playing;
          _hasAutoPlayed = true;
          notifyListeners();
        }
      }
      
      print('Music playing state: $_isPlaying (player.playing: ${_player.playing})');
    } catch (e) {
      print('Error playing background music: $e');
      _isPlaying = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Dừng nhạc
  Future<void> pause() async {
    try {
      await _player.pause();
      // Đồng bộ với state thực tế
      _isPlaying = _player.playing;
      notifyListeners();
    } catch (e) {
      print('Error pausing background music: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Dừng nhạc hoàn toàn
  Future<void> stop() async {
    try {
      await _player.stop();
      // Đồng bộ với state thực tế
      _isPlaying = _player.playing;
      notifyListeners();
    } catch (e) {
      print('Error stopping background music: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Phát track hiện tại
  Future<void> _playCurrentTrack() async {
    if (_currentTrackIndex >= _tracks.length) {
      _currentTrackIndex = 0;
    }

    try {
      print('Loading asset: ${_tracks[_currentTrackIndex]}');
      
      // Stop player trước để reset state (đặc biệt quan trọng trên web)
      if (_player.processingState != ProcessingState.idle) {
        try {
          await _player.stop();
        } catch (e) {
          print('Error stopping before load: $e');
        }
      }
      
      await _player.setAsset(_tracks[_currentTrackIndex]);
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(_volume);
      
      print('Playing music with volume $_volume, platform: web=${kIsWeb}');
      
      // Chờ một chút để đảm bảo audio context sẵn sàng (quan trọng cho web)
      if (kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      await _player.play();
      
      // Đợi một chút để đảm bảo player state được cập nhật (quan trọng cho web)
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Đồng bộ _isPlaying với state thực tế từ player
      _isPlaying = _player.playing;
      notifyListeners();
      print('Music started successfully, playing=$_isPlaying');
    } catch (e) {
      print('Error loading track ${_tracks[_currentTrackIndex]}: $e');
      _isPlaying = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Chuyển track
  Future<void> nextTrack() async {
    _currentTrackIndex = (_currentTrackIndex + 1) % _tracks.length;
    await _playCurrentTrack();
    notifyListeners();
  }

  /// Trở lại track trước
  Future<void> previousTrack() async {
    _currentTrackIndex = (_currentTrackIndex - 1 + _tracks.length) % _tracks.length;
    await _playCurrentTrack();
    notifyListeners();
  }

  /// Chọn track theo index
  Future<void> selectTrack(int index) async {
    if (index >= 0 && index < _tracks.length) {
      _currentTrackIndex = index;
      await _playCurrentTrack();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}






