enum AudioType { meditation, whiteNoise }

class AudioItem {
  final String id;
  final String title;
  final String description;
  final String coverImage;
  final String audioPath;
  final int duration; // 秒数
  final AudioType type; // 冥想/白噪音
  final String category; // 分类
  final bool isFavorite;

  AudioItem({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.audioPath,
    required this.duration,
    required this.type,
    required this.category,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverImage': coverImage,
      'audioPath': audioPath,
      'duration': duration,
      'type': type.name,
      'category': category,
      'isFavorite': isFavorite,
    };
  }

  factory AudioItem.fromJson(Map<String, dynamic> json) {
    return AudioItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      coverImage: json['coverImage'],
      audioPath: json['audioPath'],
      duration: json['duration'],
      type: AudioType.values.firstWhere((e) => e.name == json['type']),
      category: json['category'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  AudioItem copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImage,
    String? audioPath,
    int? duration,
    AudioType? type,
    String? category,
    bool? isFavorite,
  }) {
    return AudioItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      audioPath: audioPath ?? this.audioPath,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
} 