// 审核状态枚举
enum PostStatus {
  pending,    // 审核中
  approved,   // 已通过
  rejected,   // 已拒绝
}

class Post {
  final String id;
  final String content;
  final String? imageUrl;
  final List<String> tags;
  final DateTime createdAt;
  final String authorAvatar;
  final String authorName;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isBookmarked;
  final PostStatus status; // 审核状态

  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.tags,
    required this.createdAt,
    required this.authorAvatar,
    required this.authorName,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.status = PostStatus.approved, // 默认为已通过（现有动态）
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'imageUrl': imageUrl,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'authorAvatar': authorAvatar,
      'authorName': authorName,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'status': status.name,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags']),
      createdAt: DateTime.parse(json['createdAt']),
      authorAvatar: json['authorAvatar'],
      authorName: json['authorName'],
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      status: PostStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PostStatus.approved,
      ),
    );
  }

  Post copyWith({
    String? id,
    String? content,
    String? imageUrl,
    List<String>? tags,
    DateTime? createdAt,
    String? authorAvatar,
    String? authorName,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isBookmarked,
    PostStatus? status,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      authorName: authorName ?? this.authorName,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      status: status ?? this.status,
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

  // 获取审核状态的显示文本
  String get statusText {
    switch (status) {
      case PostStatus.pending:
        return '审核中';
      case PostStatus.approved:
        return '已通过';
      case PostStatus.rejected:
        return '未通过';
    }
  }

  // 获取审核状态的颜色
  String get statusColor {
    switch (status) {
      case PostStatus.pending:
        return 'orange';
      case PostStatus.approved:
        return 'green';
      case PostStatus.rejected:
        return 'red';
    }
  }
} 