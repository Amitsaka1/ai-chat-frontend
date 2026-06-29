class MessageModel {
  final String id;
  final String role;
  final String content;
  final int tokensUsed;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.role,
    required this.content,
    this.tokensUsed = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isUser => role == 'user';

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      role: json['role'] ?? '',
      content: json['content'] ?? '',
      tokensUsed: json['tokensUsed'] ?? 0,
    );
  }

  MessageModel copyWith({
    String? id,
    String? role,
    String? content,
    int? tokensUsed,
  }) {
    return MessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      tokensUsed: tokensUsed ?? this.tokensUsed,
    );
  }
}
