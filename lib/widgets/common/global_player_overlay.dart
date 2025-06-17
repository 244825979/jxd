import 'package:flutter/material.dart';
import '../../services/player_service.dart';
import 'floating_player.dart';

class GlobalPlayerOverlay extends StatelessWidget {
  final Widget child;

  const GlobalPlayerOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PlayerService(),
      builder: (context, _) {
        final playerService = PlayerService();
        
        return Stack(
          children: [
            child,
            if (playerService.isPlayerVisible && playerService.currentTrack != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 80, // 为底部tabbar留出空间
                child: FloatingPlayer(
                  currentTrack: playerService.currentTrack!,
                  isPlaying: playerService.isPlaying,
                  onClose: () => playerService.closePlayer(),
                  onPlayPause: () => playerService.togglePlayPause(),
                  onPrevious: () => playerService.playPrevious(),
                  onNext: () => playerService.playNext(),
                ),
              ),
          ],
        );
      },
    );
  }
} 