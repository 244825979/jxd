class MoodRecord {
  final String id;
  final DateTime date;
  final int moodValue; // 1-5心情等级
  final String moodEmoji; // 心情表情
  final String? note; // 文字记录
  final String? voiceNote; // 语音记录路径

  MoodRecord({
    required this.id,
    required this.date,
    required this.moodValue,
    required this.moodEmoji,
    this.note,
    this.voiceNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moodValue': moodValue,
      'moodEmoji': moodEmoji,
      'note': note,
      'voiceNote': voiceNote,
    };
  }

  factory MoodRecord.fromJson(Map<String, dynamic> json) {
    return MoodRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      moodValue: json['moodValue'],
      moodEmoji: json['moodEmoji'],
      note: json['note'],
      voiceNote: json['voiceNote'],
    );
  }

  MoodRecord copyWith({
    String? id,
    DateTime? date,
    int? moodValue,
    String? moodEmoji,
    String? note,
    String? voiceNote,
  }) {
    return MoodRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      moodValue: moodValue ?? this.moodValue,
      moodEmoji: moodEmoji ?? this.moodEmoji,
      note: note ?? this.note,
      voiceNote: voiceNote ?? this.voiceNote,
    );
  }
} 