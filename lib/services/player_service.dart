import 'package:flutter/material.dart';
import 'audio_service.dart';
import 'data_service.dart';

class PlayerService extends ChangeNotifier {
  static final PlayerService _instance = PlayerService._internal();
  factory PlayerService() => _instance;
  PlayerService._internal() {
    _audioService = AudioService.getInstance();
    _dataService = DataService.getInstance();
    _initializeAudioService();
  }

  late AudioService _audioService;
  late DataService _dataService;

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

  // 初始化AudioService
  void _initializeAudioService() {
    _audioService.initialize();
    
    // 监听音频播放状态变化
    _audioService.playerStateStream.listen((state) {
      bool wasPlaying = _isPlaying;
      switch (state) {
        case PlayerState.playing:
          _isPlaying = true;
          break;
        case PlayerState.paused:
          _isPlaying = false;
          break;
        case PlayerState.stopped:
          _isPlaying = false;
          break;
      }
      if (wasPlaying != _isPlaying) {
        notifyListeners();
      }
    });
  }

  // 播放音频
  void playTrack(Map<String, dynamic> track, {List<Map<String, dynamic>>? playlist}) {
    _currentTrack = track;
    _isPlayerVisible = true;
    
    if (playlist != null) {
      _playlist = playlist;
      _currentIndex = playlist.indexOf(track);
    } else {
      _playlist = [track];
      _currentIndex = 0;
    }
    
    // 实际播放音频
    _playCurrentAudio();
    
    notifyListeners();
  }

  // 播放当前音频
  Future<void> _playCurrentAudio() async {
    if (_currentTrack == null) return;
    
    // 根据audioId获取AudioItem
    final audioId = _currentTrack!['audioId'];
    final audioItem = _dataService.getAudioById(audioId);
    
    if (audioItem != null) {
      await _audioService.play(audioItem);
      _isPlaying = true;
    }
  }

  // 播放/暂停切换
  void togglePlayPause() {
    if (_isPlaying) {
      _audioService.pause();
    } else {
      _audioService.resume();
    }
    // 状态会通过监听器自动更新
  }

  // 上一首
  void playPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _currentTrack = _playlist[_currentIndex];
      _playCurrentAudio();
      notifyListeners();
    }
  }

  // 下一首
  void playNext() {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      _currentTrack = _playlist[_currentIndex];
      _playCurrentAudio();
      notifyListeners();
    }
  }

  // 关闭播放器
  void closePlayer() {
    _audioService.stop();
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