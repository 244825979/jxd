import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

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
  int _currentSeconds = 0; // 当前播放时间（秒）
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
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
    _startProgressTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(FloatingPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startProgressTimer();
      } else {
        _stopProgressTimer();
      }
    }
    if (widget.currentTrack != oldWidget.currentTrack) {
      setState(() {
        _currentSeconds = 0;
      });
      if (widget.isPlaying) {
        _startProgressTimer();
      }
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    if (widget.isPlaying) {
      _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && widget.isPlaying) {
          setState(() {
            _currentSeconds++;
            // 模拟5分钟音频，循环播放
            if (_currentSeconds >= 300) {
              _currentSeconds = 0;
            }
          });
        }
      });
    }
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
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
                              '${_formatTime(_currentSeconds)} / ${_getTotalDuration()}',
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
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 获取总时长
  String _getTotalDuration() {
    // 从音频数据中获取时长，如果没有则默认5分钟
    String? duration = widget.currentTrack['duration'];
    if (duration != null) {
      // 解析时长字符串，如 "5分钟" -> "05:00"
      if (duration.contains('分钟')) {
        int minutes = int.tryParse(duration.replaceAll('分钟', '')) ?? 5;
        return _formatTime(minutes * 60);
      }
    }
    return '05:00'; // 默认5分钟
  }
} 