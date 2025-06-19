import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/data_service.dart';
import '../../models/notification.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/ai_avatar.dart';
import '../home/ai_chat_screen.dart';
import 'feedback_screen.dart';

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notification.isRead 
            ? Colors.transparent 
            : AppColors.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: notification.isRead 
              ? Colors.transparent 
              : AppColors.accent.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              size: 16,
              color: AppColors.accent,
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
    );
  }
} 