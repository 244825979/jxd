import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/audio_service.dart';

class FloatingPlayer extends StatefulWidget {
  final Map<String, dynamic> currentTrack;
  final VoidCallback onClose;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isPlaying;
  final VoidCallback onPlayPause;

  const FloatingPlayer({
    super.key,
    required this.currentTrack,
    required this.onClose,
    required this.onPrevious,
    required this.onNext,
    required this.isPlaying,
    required this.onPlayPause,
  });

  @override
  State<FloatingPlayer> createState() => _FloatingPlayerState();
}

class _FloatingPlayerState extends State<FloatingPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late AudioService _audioService;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService.getInstance();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    _setupAudioStreams();
  }

  void _setupAudioStreams() {
    // 监听播放位置变化
    _positionSubscription = _audioService.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    // 监听音频总时长变化
    _durationSubscription = _audioService.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    // 初始化当前值
    _currentPosition = _audioService.currentPosition;
    _totalDuration = _audioService.totalDuration;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(FloatingPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当切换音频时，重新获取时长信息
    if (widget.currentTrack != oldWidget.currentTrack) {
      // 重新获取当前的播放状态
      _currentPosition = _audioService.currentPosition;
      _totalDuration = _audioService.totalDuration;
    }
  }

  void _handleClose() async {
    await _animationController.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 主内容区域
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // 播放/暂停按钮
                      GestureDetector(
                        onTap: widget.onPlayPause,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.accent,
                                AppColors.accent.withOpacity(0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // 音乐标题
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.currentTrack['title'] ?? '未知标题',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 控制按钮组
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 上一首
                          GestureDetector(
                            onTap: widget.onPrevious,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.skip_previous,
                                color: AppColors.accent,
                                size: 20,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 下一首
                          GestureDetector(
                            onTap: widget.onNext,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.skip_next,
                                color: AppColors.accent,
                                size: 20,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 关闭按钮
                          GestureDetector(
                            onTap: _handleClose,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: AppColors.textHint,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 格式化时间显示 (mm:ss)
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
} 