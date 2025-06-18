class User {
  final String id;
  final String nickname;
  final String avatar;
  final int likeCount;
  final int collectionCount;
  final int postCount;
  final DateTime joinDate;
  final String mood;

  User({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.likeCount,
    required this.collectionCount,
    required this.postCount,
    required this.joinDate,
    required this.mood,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      nickname: json['nickname'] ?? '',
      avatar: json['avatar'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      collectionCount: json['collectionCount'] ?? 0,
      postCount: json['postCount'] ?? 0,
      joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
      mood: json['mood'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'likeCount': likeCount,
      'collectionCount': collectionCount,
      'postCount': postCount,
      'joinDate': joinDate.toIso8601String(),
      'mood': mood,
    };
  }

  User copyWith({
    String? id,
    String? nickname,
    String? avatar,
    int? likeCount,
    int? collectionCount,
    int? postCount,
    DateTime? joinDate,
    String? mood,
  }) {
    return User(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      likeCount: likeCount ?? this.likeCount,
      collectionCount: collectionCount ?? this.collectionCount,
      postCount: postCount ?? this.postCount,
      joinDate: joinDate ?? this.joinDate,
      mood: mood ?? this.mood,
    );
  }

  // 获取用户加入天数
  int get daysSinceJoin {
    return DateTime.now().difference(joinDate).inDays;
  }

  // 获取用户等级（基于活跃度）
  String get userLevel {
    final totalActivity = likeCount + collectionCount + postCount;
    if (totalActivity >= 100) return '活跃用户';
    if (totalActivity >= 50) return '常规用户';
    if (totalActivity >= 10) return '新手用户';
    return '初来乍到';
  }
} 