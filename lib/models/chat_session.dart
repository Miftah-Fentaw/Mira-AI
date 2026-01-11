class ChatSession {
  final String id;
  final String title;
  final DateTime lastMessageAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.lastMessageAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'] as String,
        title: json['title'] as String,
        lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'lastMessageAt': lastMessageAt.toIso8601String(),
      };

  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? lastMessageAt,
  }) =>
      ChatSession(
        id: id ?? this.id,
        title: title ?? this.title,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      );
}
