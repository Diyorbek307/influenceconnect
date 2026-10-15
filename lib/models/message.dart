/// Сообщение в чате между брендом и блогером.
class Message {
  final String id;
  final String fromId;
  final String toId;
  final String text;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromId': fromId,
        'toId': toId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        fromId: json['fromId'] as String,
        toId: json['toId'] as String,
        text: json['text'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
