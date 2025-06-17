class MoodRecord {
  final String id;
  final DateTime date;
  final String moodEmoji;
  final int moodValue; // 1-5 心情指数
  final String? note; // 心情内容
  final String? title; // 心情标题

  MoodRecord({
    required this.id,
    required this.date,
    required this.moodEmoji,
    required this.moodValue,
    this.note,
    this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moodEmoji': moodEmoji,
      'moodValue': moodValue,
      'note': note,
      'title': title,
    };
  }

  factory MoodRecord.fromJson(Map<String, dynamic> json) {
    return MoodRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      moodEmoji: json['moodEmoji'] as String,
      moodValue: json['moodValue'] as int,
      note: json['note'] as String?,
      title: json['title'] as String?,
    );
  }

  MoodRecord copyWith({
    String? id,
    DateTime? date,
    String? moodEmoji,
    int? moodValue,
    String? note,
    String? title,
  }) {
    return MoodRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      moodEmoji: moodEmoji ?? this.moodEmoji,
      moodValue: moodValue ?? this.moodValue,
      note: note ?? this.note,
      title: title ?? this.title,
    );
  }

  @override
  String toString() {
    return 'MoodRecord(id: $id, date: $date, moodEmoji: $moodEmoji, moodValue: $moodValue, note: $note, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodRecord &&
        other.id == id &&
        other.date == date &&
        other.moodEmoji == moodEmoji &&
        other.moodValue == moodValue &&
        other.note == note &&
        other.title == title;
  }

  @override
  int get hashCode {
    return Object.hash(id, date, moodEmoji, moodValue, note, title);
  }
} 