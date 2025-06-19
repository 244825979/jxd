import 'package:flutter/material.dart';

// 举报审核状态枚举
enum ReportStatus {
  pending,    // 审核中
  approved,   // 举报成立
  rejected,   // 举报不成立
  processing, // 处理中
}

// 举报处理结果枚举
enum ReportResult {
  none,           // 无结果（审核中）
  contentRemoved, // 内容已删除
  userWarned,     // 用户已警告
  userBanned,     // 用户已封禁
  noViolation,    // 未发现违规
}

class Report {
  final String id;
  final String reporterId;        // 举报者ID
  final String reporterName;      // 举报者昵称
  final String postId;            // 被举报动态ID
  final String postAuthorId;      // 被举报动态作者ID
  final String postAuthorName;    // 被举报动态作者名称
  final String postContent;       // 被举报内容（缓存）
  final String reason;            // 举报原因
  final String reasonText;        // 举报原因文本
  final String? detail;           // 详细说明
  final DateTime createdAt;       // 举报时间
  final DateTime? reviewedAt;     // 审核时间
  final String? reviewerId;       // 审核员ID
  final String? reviewerName;     // 审核员名称
  final ReportStatus status;      // 审核状态
  final ReportResult result;      // 处理结果
  final String? resultNote;       // 处理说明

  Report({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.postId,
    required this.postAuthorId,
    required this.postAuthorName,
    required this.postContent,
    required this.reason,
    required this.reasonText,
    this.detail,
    required this.createdAt,
    this.reviewedAt,
    this.reviewerId,
    this.reviewerName,
    this.status = ReportStatus.pending,
    this.result = ReportResult.none,
    this.resultNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'postId': postId,
      'postAuthorId': postAuthorId,
      'postAuthorName': postAuthorName,
      'postContent': postContent,
      'reason': reason,
      'reasonText': reasonText,
      'detail': detail,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'status': status.name,
      'result': result.name,
      'resultNote': resultNote,
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      reporterId: json['reporterId'],
      reporterName: json['reporterName'],
      postId: json['postId'],
      postAuthorId: json['postAuthorId'],
      postAuthorName: json['postAuthorName'],
      postContent: json['postContent'],
      reason: json['reason'],
      reasonText: json['reasonText'],
      detail: json['detail'],
      createdAt: DateTime.parse(json['createdAt']),
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      reviewerId: json['reviewerId'],
      reviewerName: json['reviewerName'],
      status: ReportStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      result: ReportResult.values.firstWhere(
        (r) => r.name == json['result'],
        orElse: () => ReportResult.none,
      ),
      resultNote: json['resultNote'],
    );
  }

  Report copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? postId,
    String? postAuthorId,
    String? postAuthorName,
    String? postContent,
    String? reason,
    String? reasonText,
    String? detail,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewerId,
    String? reviewerName,
    ReportStatus? status,
    ReportResult? result,
    String? resultNote,
  }) {
    return Report(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      postId: postId ?? this.postId,
      postAuthorId: postAuthorId ?? this.postAuthorId,
      postAuthorName: postAuthorName ?? this.postAuthorName,
      postContent: postContent ?? this.postContent,
      reason: reason ?? this.reason,
      reasonText: reasonText ?? this.reasonText,
      detail: detail ?? this.detail,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      status: status ?? this.status,
      result: result ?? this.result,
      resultNote: resultNote ?? this.resultNote,
    );
  }

  // 获取状态显示文本
  String get statusText {
    switch (status) {
      case ReportStatus.pending:
        return '审核中';
      case ReportStatus.processing:
        return '处理中';
      case ReportStatus.approved:
        return '举报成立';
      case ReportStatus.rejected:
        return '举报不成立';
    }
  }

  // 获取状态颜色
  Color get statusColor {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.processing:
        return Colors.blue;
      case ReportStatus.approved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }

  // 获取处理结果显示文本
  String get resultText {
    switch (result) {
      case ReportResult.none:
        return '等待处理';
      case ReportResult.contentRemoved:
        return '内容已删除';
      case ReportResult.userWarned:
        return '用户已警告';
      case ReportResult.userBanned:
        return '用户已封禁';
      case ReportResult.noViolation:
        return '未发现违规';
    }
  }

  // 获取举报原因映射
  static Map<String, String> get reasonMap {
    return {
      'inappropriate_content': '不当内容',
      'harassment': '骚扰辱骂',
      'false_info': '虚假信息',
      'spam': '垃圾信息',
      'privacy_violation': '侵犯隐私',
      'other': '其他原因',
    };
  }

  // 获取时间显示
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

  // 获取审核时间显示
  String? get reviewTimeAgo {
    if (reviewedAt == null) return null;
    
    final now = DateTime.now();
    final difference = now.difference(reviewedAt!);

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

  // 检查是否超过24小时
  bool get isOver24Hours {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours >= 24;
  }

  // 获取审核剩余时间显示
  String get reviewTimeLeft {
    if (status != ReportStatus.pending) {
      return '';
    }
    
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    final hoursLeft = 24 - difference.inHours;
    
    if (hoursLeft <= 0) {
      return '即将完成审核';
    } else {
      return '预计${hoursLeft}小时后完成审核';
    }
  }
} 