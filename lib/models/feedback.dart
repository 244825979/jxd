class Feedback {
  final String id;
  final String type;
  final String content;
  final String? contact;
  final DateTime createdAt;
  final FeedbackStatus status;
  final String? response;
  final DateTime? responseAt;

  Feedback({
    required this.id,
    required this.type,
    required this.content,
    this.contact,
    required this.createdAt,
    this.status = FeedbackStatus.pending,
    this.response,
    this.responseAt,
  });

  Feedback copyWith({
    String? id,
    String? type,
    String? content,
    String? contact,
    DateTime? createdAt,
    FeedbackStatus? status,
    String? response,
    DateTime? responseAt,
  }) {
    return Feedback(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      contact: contact ?? this.contact,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      response: response ?? this.response,
      responseAt: responseAt ?? this.responseAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'contact': contact,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'response': response,
      'responseAt': responseAt?.toIso8601String(),
    };
  }

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      contact: json['contact'],
      createdAt: DateTime.parse(json['createdAt']),
      status: FeedbackStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => FeedbackStatus.pending,
      ),
      response: json['response'],
      responseAt: json['responseAt'] != null 
          ? DateTime.parse(json['responseAt'])
          : null,
    );
  }

  String get statusText {
    switch (status) {
      case FeedbackStatus.pending:
        return '处理中';
      case FeedbackStatus.replied:
        return '已回复';
      case FeedbackStatus.resolved:
        return '已解决';
    }
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

enum FeedbackStatus {
  pending,   // 处理中
  replied,   // 已回复
  resolved,  // 已解决
} 