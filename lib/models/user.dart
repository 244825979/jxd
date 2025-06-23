class User {
  final String id;
  final String nickname;
  final String avatar;
  final int likeCount;
  final int collectionCount;
  final int postCount;
  final DateTime joinDate;
  final String mood;
  final bool isVip;

  User({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.likeCount,
    required this.collectionCount,
    required this.postCount,
    required this.joinDate,
    required this.mood,
    this.isVip = false,
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
      isVip: json['isVip'] ?? false,
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
      'isVip': isVip,
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
    bool? isVip,
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
      isVip: isVip ?? this.isVip,
    );
  }

  // 获取用户加入天数
  int get daysSinceJoin {
    return DateTime.now().difference(joinDate).inDays;
  }

  // 获取用户等级（VIP标识）
  String get userLevel {
    return 'VIP';
  }
} 