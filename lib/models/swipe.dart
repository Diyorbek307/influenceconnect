/// Действие свайпа: бренд оценивает блогера, либо блогер оценивает кампанию.
class Swipe {
  final String id;
  final String fromId; // кто свайпнул
  final String targetType; // 'blogger' | 'campaign'
  final String targetId; // id блогера или кампании
  final bool liked; // true — лайк/сохранение, false — пропуск
  final DateTime createdAt;

  Swipe({
    required this.id,
    required this.fromId,
    required this.targetType,
    required this.targetId,
    required this.liked,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromId': fromId,
        'targetType': targetType,
        'targetId': targetId,
        'liked': liked,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Swipe.fromJson(Map<String, dynamic> json) => Swipe(
        id: json['id'] as String,
        fromId: json['fromId'] as String,
        targetType: json['targetType'] as String,
        targetId: json['targetId'] as String,
        liked: json['liked'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
