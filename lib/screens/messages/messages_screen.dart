import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/data_service.dart';
import '../../models/notification.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/ai_avatar.dart';
import '../home/ai_chat_screen.dart';
import '../profile/my_posts_screen.dart';
import 'feedback_screen.dart';
import 'wellness_tips_screen.dart';
import 'achievements_screen.dart';
import 'feature_intro_screen.dart';
import 'coming_soon_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late DataService _dataService;
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _dataService = DataService.getInstance();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = _dataService.getNotifications();
    });
  }

  void _navigateToAIChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AIChatScreen(),
      ),
    );
  }

  void _navigateToFeedback() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FeedbackScreen(),
      ),
    );
  }

  void _navigateToWellnessTips() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WellnessTipsScreen(),
      ),
    );
  }

  void _navigateToAchievements() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AchievementsScreen(),
      ),
    );
  }

  void _navigateToFeatureIntro(Map<String, dynamic>? params) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeatureIntroScreen(feature: params?['feature']),
      ),
    );
  }

  void _navigateToMyPosts() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MyPostsScreen(),
      ),
    );
  }

  void _navigateToComingSoon() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ComingSoonScreen(),
      ),
    );
  }

  void _showNotificationDetail(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.aiReminder:
        return Icons.notifications;
      case NotificationType.comment:
        return Icons.chat_bubble;
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.wellness:
        return Icons.health_and_safety;
      case NotificationType.achievement:
        return Icons.emoji_events;
    }
  }

  Color _getNotificationIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.aiReminder:
        return Colors.blue.shade400;
      case NotificationType.comment:
        return Colors.green.shade400;
      case NotificationType.like:
        return Colors.red.shade400;
      case NotificationType.system:
        return Colors.purple.shade400;
      case NotificationType.wellness:
        return Colors.teal.shade400;
      case NotificationType.achievement:
        return Colors.amber.shade400;
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    // 标记为已读
    notification = notification.copyWith(isRead: true);
    
    // 根据routeName导航到对应页面
    if (notification.routeName != null) {
      switch (notification.routeName) {
        case '/wellness_tips':
          _navigateToWellnessTips();
          break;
        case '/achievements':
          _navigateToAchievements();
          break;
        case '/feature_intro':
          _navigateToFeatureIntro(notification.routeParams);
          break;
        case '/ai_chat':
          _navigateToAIChat();
          break;
        case '/my_posts':
          _navigateToMyPosts();
          break;
        case '/coming_soon':
          _navigateToComingSoon();
          break;
        default:
          _showNotificationDetail(notification);
      }
    } else {
      _showNotificationDetail(notification);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          AppStrings.messagesTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.feedback_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: _navigateToFeedback,
            tooltip: '意见反馈',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI 心伴私密对话入口
            CustomCard(
              onTap: _navigateToAIChat,
              child: Row(
                children: [
                  const AIAvatar(
                    size: 60,
                    backgroundColor: AppColors.accent,
                    iconSize: 30,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.aiChat,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '与AI助手分享你的情感世界',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 通知中心
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.notifications,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_notifications.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 48,
                              color: AppColors.textHint,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '暂无新通知',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...(_notifications.map((notification) => 
                      _buildNotificationItem(notification))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    final iconColor = _getNotificationIconColor(notification.type);
    
    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.isRead 
              ? Colors.transparent 
              : iconColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: notification.isRead 
                ? Colors.transparent 
                : iconColor.withOpacity(0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                size: 16,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead 
                                ? FontWeight.w500 
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        notification.timeAgo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  if (notification.content.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.content,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
} 