import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  final bool showCircleBackground;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool filled;

  const AppLogo({
    super.key,
    this.size = 60,
    this.showShadow = true,
    this.showCircleBackground = true,
    this.backgroundColor,
    this.padding,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget logoWidget = Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: filled ? BoxFit.cover : BoxFit.contain,
    );

    if (showCircleBackground) {
      logoWidget = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? Colors.white,
          boxShadow: showShadow ? [
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: ClipOval(
          child: Padding(
            padding: padding ?? EdgeInsets.all(filled ? 0 : size * 0.15),
            child: Image.asset(
              'assets/images/logo.png',
              fit: filled ? BoxFit.cover : BoxFit.contain,
            ),
          ),
        ),
      );
    } else if (showShadow) {
      logoWidget = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: logoWidget,
      );
    }

    return logoWidget;
  }

  // 预设样式
  factory AppLogo.small({Color? backgroundColor, bool filled = true}) {
    return AppLogo(
      size: 32,
      backgroundColor: backgroundColor,
      padding: filled ? EdgeInsets.zero : const EdgeInsets.all(6),
      filled: filled,
    );
  }

  factory AppLogo.medium({Color? backgroundColor, bool filled = true}) {
    return AppLogo(
      size: 48,
      backgroundColor: backgroundColor,
      padding: filled ? EdgeInsets.zero : const EdgeInsets.all(8),
      filled: filled,
    );
  }

  factory AppLogo.large({Color? backgroundColor, bool filled = true}) {
    return AppLogo(
      size: 80,
      backgroundColor: backgroundColor,
      padding: filled ? EdgeInsets.zero : const EdgeInsets.all(12),
      filled: filled,
    );
  }

  factory AppLogo.hero({Color? backgroundColor, bool filled = true}) {
    return AppLogo(
      size: 120,
      backgroundColor: backgroundColor,
      padding: filled ? EdgeInsets.zero : const EdgeInsets.all(20),
      filled: filled,
    );
  }

  // 简单版本（无背景圆圈）
  factory AppLogo.simple({double size = 60, bool filled = true}) {
    return AppLogo(
      size: size,
      showCircleBackground: false,
      showShadow: false,
      filled: filled,
    );
  }
} 