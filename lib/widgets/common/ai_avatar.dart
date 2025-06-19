import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AIAvatar extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final double? iconSize;

  const AIAvatar({
    super.key,
    this.size = 60,
    this.backgroundColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final double actualIconSize = iconSize ?? size * 0.5;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/avatars/ai_avatar.jpeg',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: actualIconSize,
              ),
            );
          },
        ),
      ),
    );
  }
} 