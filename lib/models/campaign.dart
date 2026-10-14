/// Рекламная кампания, которую создаёт бренд.
class Campaign {
  final String id;
  final String brandId;
  String title;
  String description;
  int budget; // в рублях
  String category;
  String imageUrl;
  String status; // 'active' | 'closed' | 'pending' (ждёт модерации админа)
  final DateTime createdAt;

  Campaign({
    required this.id,
    required this.brandId,
    required this.title,
    required this.description,
    required this.budget,
    required this.category,
    required this.imageUrl,
    this.status = 'active',
    required this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isClosed => status == 'closed';

  String get budgetLabel {
    final s = budget.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '$buf ₽';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'title': title,
        'description': description,
        'budget': budget,
        'category': category,
        'imageUrl': imageUrl,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
        id: json['id'] as String,
        brandId: json['brandId'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        budget: (json['budget'] as num?)?.toInt() ?? 0,
        category: json['category'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        status: json['status'] as String? ?? 'active',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
