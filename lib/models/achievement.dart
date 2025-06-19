enum AchievementType {
  welcome,         // 欢迎
  listener,        // 倾听者
  expresser,       // 表达者
  meditator,       // 冥想者
  supporter,       // 温暖使者
  tracker,         // 成长见证者
  challenger,      // 挑战者
  helper,          // 互助者
  consistent,      // 坚持者
}

class Achievement {
  final String id;
  final AchievementType type;
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final String colorHex;
  final int requiredValue;    // 达成所需的数值
  final String unit;          // 单位 (天、次、个等)
  final bool isUnlocked;      // 是否已解锁
  final DateTime? unlockedAt; // 解锁时间
  final int currentValue;     // 当前进度值

  Achievement({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.colorHex,
    required this.requiredValue,
    required this.unit,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentValue = 0,
  });

  // 进度百分比
  double get progress => currentValue / requiredValue;
  
  // 是否接近完成 (进度超过80%)
  bool get isNearComplete => progress >= 0.8 && !isUnlocked;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'icon': icon,
      'colorHex': colorHex,
      'requiredValue': requiredValue,
      'unit': unit,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'currentValue': currentValue,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      type: AchievementType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      icon: json['icon'],
      colorHex: json['colorHex'],
      requiredValue: json['requiredValue'],
      unit: json['unit'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : null,
      currentValue: json['currentValue'] ?? 0,
    );
  }

  Achievement copyWith({
    String? id,
    AchievementType? type,
    String? title,
    String? subtitle,
    String? description,
    String? icon,
    String? colorHex,
    int? requiredValue,
    String? unit,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentValue,
  }) {
    return Achievement(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      requiredValue: requiredValue ?? this.requiredValue,
      unit: unit ?? this.unit,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentValue: currentValue ?? this.currentValue,
    );
  }
} 