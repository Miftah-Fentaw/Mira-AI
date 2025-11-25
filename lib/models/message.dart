enum MessageSender { user, ai }

class Message {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    content: json['content'] as String,
    sender: MessageSender.values.firstWhere(
      (e) => e.name == json['sender'],
      orElse: () => MessageSender.user,
    ),
    timestamp: DateTime.parse(json['timestamp'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'sender': sender.name,
    'timestamp': timestamp.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  Message copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Message(
    id: id ?? this.id,
    content: content ?? this.content,
    sender: sender ?? this.sender,
    timestamp: timestamp ?? this.timestamp,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
