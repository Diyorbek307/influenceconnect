/// Единая модель пользователя: бренд, блогер или админ.
///
/// Пароль хранится здесь только для демо-режима (локальный бэкенд).
/// При подключении Supabase аутентификацию возьмёт на себя сервер.
class Profile {
  final String id;
  String email;
  String password;
  String role; // 'brand' | 'blogger' | 'admin' | '' (роль не выбрана)
  String name;
  String avatarUrl;
  String bio;
  String category; // ниша блогера / индустрия бренда
  String location;
  String platform; // Instagram / YouTube / TikTok (для блогера)
  int followers; // охват (для блогера)
  double engagement; // вовлечённость в % (для блогера)
  bool isBlocked;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.email,
    required this.password,
    this.role = '',
    this.name = '',
    this.avatarUrl = '',
    this.bio = '',
    this.category = '',
    this.location = '',
    this.platform = '',
    this.followers = 0,
    this.engagement = 0,
    this.isBlocked = false,
    required this.createdAt,
  });

  bool get isBrand => role == 'brand';
  bool get isBlogger => role == 'blogger';
  bool get isAdmin => role == 'admin';
  bool get hasRole => role.isNotEmpty;

  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  String get initials {
    final source = displayName.trim();
    if (source.isEmpty) return '?';
    final parts = source.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  /// Охват в компактном виде: 125000 -> "125K".
  String get followersLabel => _compact(followers);

  static String _compact(int n) {
    if (n >= 1000000) {
      final v = n / 1000000;
      return '${v.toStringAsFixed(v % 1 == 0 ? 0 : 1)}M';
    }
    if (n >= 1000) {
      final v = n / 1000;
      return '${v.toStringAsFixed(v % 1 == 0 ? 0 : 1)}K';
    }
    return '$n';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password': password,
        'role': role,
        'name': name,
        'avatarUrl': avatarUrl,
        'bio': bio,
        'category': category,
        'location': location,
        'platform': platform,
        'followers': followers,
        'engagement': engagement,
        'isBlocked': isBlocked,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
        role: json['role'] as String? ?? '',
        name: json['name'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        category: json['category'] as String? ?? '',
        location: json['location'] as String? ?? '',
        platform: json['platform'] as String? ?? '',
        followers: (json['followers'] as num?)?.toInt() ?? 0,
        engagement: (json['engagement'] as num?)?.toDouble() ?? 0,
        isBlocked: json['isBlocked'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
