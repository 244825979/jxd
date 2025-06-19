enum NotificationType { 
  aiReminder,       // AI智能提醒
  comment,          // 评论通知
  like,             // 点赞通知
  system,           // 系统公告
  wellness,         // 健康贴士
  achievement       // 成就徽章
}

class NotificationItem {
  final String id;
  final String title;
  final String content;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? routeName;       // 目标页面路由
  final Map<String, dynamic>? routeParams; // 路由参数

  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.routeName,
    this.routeParams,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'routeName': routeName,
      'routeParams': routeParams,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      routeName: json['routeName'],
      routeParams: json['routeParams'] != null 
          ? Map<String, dynamic>.from(json['routeParams']) 
          : null,
    );
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? content,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? routeName,
    Map<String, dynamic>? routeParams,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      routeName: routeName ?? this.routeName,
      routeParams: routeParams ?? this.routeParams,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
} 