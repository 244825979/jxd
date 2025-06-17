import 'package:flutter/material.dart';

class PlayerService extends ChangeNotifier {
  static final PlayerService _instance = PlayerService._internal();
  factory PlayerService() => _instance;
  PlayerService._internal();

  Map<String, dynamic>? _currentTrack;
  bool _isPlaying = false;
  bool _isPlayerVisible = false;
  int _currentIndex = -1;
  List<Map<String, dynamic>> _playlist = [];

  // Getters
  Map<String, dynamic>? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  bool get isPlayerVisible => _isPlayerVisible;
  int get currentIndex => _currentIndex;
  List<Map<String, dynamic>> get playlist => _playlist;

  // 播放音频
  void playTrack(Map<String, dynamic> track, {List<Map<String, dynamic>>? playlist}) {
    _currentTrack = track;
    _isPlaying = true;
    _isPlayerVisible = true;
    
    if (playlist != null) {
      _playlist = playlist;
      _currentIndex = playlist.indexOf(track);
    } else {
      _playlist = [track];
      _currentIndex = 0;
    }
    
    notifyListeners();
  }

  // 播放/暂停切换
  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  // 上一首
  void playPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _currentTrack = _playlist[_currentIndex];
      _isPlaying = true;
      notifyListeners();
    }
  }

  // 下一首
  void playNext() {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      _currentTrack = _playlist[_currentIndex];
      _isPlaying = true;
      notifyListeners();
    }
  }

  // 关闭播放器
  void closePlayer() {
    _currentTrack = null;
    _isPlaying = false;
    _isPlayerVisible = false;
    _currentIndex = -1;
    _playlist.clear();
    notifyListeners();
  }

  // 隐藏播放器（但不停止播放）
  void hidePlayer() {
    _isPlayerVisible = false;
    notifyListeners();
  }

  // 显示播放器
  void showPlayer() {
    if (_currentTrack != null) {
      _isPlayerVisible = true;
      notifyListeners();
    }
  }
} 