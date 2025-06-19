import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String avatarPath;
  final double size;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    required this.avatarPath,
    this.size = 32,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: ClipOval(
        child: Image.asset(
          avatarPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.accent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: AppColors.accent,
                size: size * 0.6,
              ),
            );
          },
        ),
      ),
    );
  }
} 