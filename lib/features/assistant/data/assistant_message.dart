class AssistantMessage {
  final int? id;
  final String? userId;
  final String role; // 'user' or 'assistant'
  final String message;
  final DateTime timestamp;

  AssistantMessage({
    this.id,
    this.userId,
    required this.role,
    required this.message,
    required this.timestamp,
  });

  factory AssistantMessage.fromMap(Map<String, dynamic> map) {
    return AssistantMessage(
      id: map['id'] as int?,
      userId: map['user_id'] as String?,
      role: map['role'] as String,
      message: map['message'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'role': role,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
