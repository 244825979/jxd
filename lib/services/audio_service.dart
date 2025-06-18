import 'dart:async';
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import '../models/audio_item.dart';

enum PlayerState { stopped, playing, paused }

class AudioService {
  static AudioService? _instance;
  AudioService._();

  static AudioService getInstance() {
    return _instance ??= AudioService._();
  }

  final audioplayers.AudioPlayer _audioPlayer = audioplayers.AudioPlayer();
  
  // 当前播放状态
  PlayerState _playerState = PlayerState.stopped;
  AudioItem? _currentAudio;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _timer;
  int? _timerDuration; // 定时关闭时间（秒）
  bool _isLooping = true; // 是否循环播放

  // 状态流控制器
  final StreamController<PlayerState> _playerStateController = StreamController<PlayerState>.broadcast();
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast();
  final StreamController<AudioItem?> _currentAudioController = StreamController<AudioItem?>.broadcast();
  final StreamController<int?> _timerController = StreamController<int?>.broadcast();
  final StreamController<bool> _loopController = StreamController<bool>.broadcast();

  // 公开的流
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<AudioItem?> get currentAudioStream => _currentAudioController.stream;
  Stream<int?> get timerStream => _timerController.stream;
  Stream<bool> get loopStream => _loopController.stream;

  // Getters
  PlayerState get playerState => _playerState;
  AudioItem? get currentAudio => _currentAudio;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  int? get timerDuration => _timerDuration;
  bool get isLooping => _isLooping;

  // 初始化
  Future<void> initialize() async {
    // 监听播放位置变化
    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      _positionController.add(position);
    });

    // 监听总时长变化
    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      _durationController.add(duration);
    });

    // 监听播放状态变化
    _audioPlayer.onPlayerStateChanged.listen((state) {
      switch (state) {
        case audioplayers.PlayerState.playing:
          _updatePlayerState(PlayerState.playing);
          break;
        case audioplayers.PlayerState.paused:
          _updatePlayerState(PlayerState.paused);
          break;
        case audioplayers.PlayerState.stopped:
        case audioplayers.PlayerState.completed:
          _updatePlayerState(PlayerState.stopped);
          break;
        case audioplayers.PlayerState.disposed:
          _updatePlayerState(PlayerState.stopped);
          break;
      }
    });

    // 监听播放完成
    _audioPlayer.onPlayerComplete.listen((_) async {
      if (_isLooping && _currentAudio != null && _timerDuration == null) {
        // 循环播放：重新开始播放
        _currentPosition = Duration.zero;
        _positionController.add(_currentPosition);
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.resume();
      } else {
        // 不循环或有定时器：停止播放
        _updatePlayerState(PlayerState.stopped);
        _currentPosition = Duration.zero;
        _positionController.add(_currentPosition);
      }
    });
  }

  // 播放音频
  Future<void> play(AudioItem audioItem) async {
    try {
      if (_currentAudio?.id != audioItem.id) {
        await stop();
        _currentAudio = audioItem;
        _currentAudioController.add(_currentAudio);
        await _audioPlayer.setSource(audioplayers.AssetSource(audioItem.audioPath));
      }
      
      await _audioPlayer.resume();
    } catch (e) {
      print('播放音频失败: $e');
    }
  }

  // 暂停播放
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('暂停播放失败: $e');
    }
  }

  // 恢复播放
  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      print('恢复播放失败: $e');
    }
  }

  // 停止播放
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _currentPosition = Duration.zero;
      _positionController.add(_currentPosition);
    } catch (e) {
      print('停止播放失败: $e');
    }
  }

  // 跳转到指定位置
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('跳转失败: $e');
    }
  }

  // 设置音量
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('设置音量失败: $e');
    }
  }

  // 设置定时关闭
  void setTimer(int minutes) {
    cancelTimer();
    _timerDuration = minutes * 60;
    _timerController.add(_timerDuration);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerDuration! > 0) {
        _timerDuration = _timerDuration! - 1;
        _timerController.add(_timerDuration);
      } else {
        stop();
        cancelTimer();
      }
    });
  }

  // 取消定时器
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _timerDuration = null;
    _timerController.add(_timerDuration);
  }

  // 设置循环播放
  void setLooping(bool loop) {
    _isLooping = loop;
    _loopController.add(_isLooping);
  }

  // 更新播放状态
  void _updatePlayerState(PlayerState state) {
    _playerState = state;
    _playerStateController.add(state);
  }

  // 释放资源
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    _timer?.cancel();
    await _playerStateController.close();
    await _positionController.close();
    await _durationController.close();
    await _currentAudioController.close();
    await _timerController.close();
    await _loopController.close();
  }

  // 格式化时间
  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 格式化定时器时间
  String formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
} 