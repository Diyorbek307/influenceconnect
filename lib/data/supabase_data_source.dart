import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/campaign.dart';
import '../models/profile.dart';
import '../models/swipe.dart';
import 'data_source.dart';
import 'supabase_config.dart';

/// Облачный источник данных на базе Supabase (общая БД для всех пользователей).
///
/// Аутентификация — через Supabase Auth, данные — в таблицах profiles /
/// campaigns / swipes (см. supabase_schema.sql). Строки БД в snake_case
/// преобразуются в модели здесь.
class SupabaseDataSource implements DataSource {
  SupabaseClient get _db => Supabase.instance.client;

  @override
  Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // В новых проектах Supabase этот ключ называется «publishable key»,
      // в старых — «anon public key». Значение одинаково подходит.
      publishableKey: SupabaseConfig.anonKey,
    );
  }

  @override
  String? currentUserId() => _db.auth.currentUser?.id;

  @override
  Future<String> register({
    required String email,
    required String password,
    required bool asAdmin,
  }) async {
    final normalized = email.trim().toLowerCase();
    try {
      final res = await _db.auth.signUp(email: normalized, password: password);
      final user = res.user;
      if (user == null) {
        throw AppException('Не удалось создать аккаунт.');
      }
      // Если после регистрации сессии нет — выполняем вход сразу
      // (email авто-подтверждается триггером в базе, см. supabase_schema.sql).
      if (res.session == null) {
        await _db.auth.signInWithPassword(email: normalized, password: password);
      }
      // Профиль создаётся триггером; дополним email и роль.
      await _db.from('profiles').update({
        'email': user.email,
        if (asAdmin) 'role': 'admin',
        if (asAdmin) 'name': 'Администратор',
      }).eq('id', user.id);
      return user.id;
    } on AuthException catch (e) {
      throw AppException(e.message);
    }
  }

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _db.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = res.user;
      if (user == null) throw AppException('Неверный email или пароль.');

      final row = await _db
          .from('profiles')
          .select('is_blocked')
          .eq('id', user.id)
          .maybeSingle();
      if (row != null && row['is_blocked'] == true) {
        await logout();
        throw AppException('Аккаунт заблокирован администратором.');
      }
      return user.id;
    } on AuthException catch (e) {
      throw AppException(e.message);
    }
  }

  @override
  Future<void> logout() => _db.auth.signOut();

  @override
  Future<List<Profile>> fetchProfiles() async {
    final rows = await _db.from('profiles').select();
    return (rows as List).map((e) => _profileFromDb(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Campaign>> fetchCampaigns() async {
    final rows = await _db.from('campaigns').select();
    return (rows as List).map((e) => _campaignFromDb(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Swipe>> fetchSwipes() async {
    final rows = await _db.from('swipes').select();
    return (rows as List).map((e) => _swipeFromDb(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveProfile(Profile p) async {
    await _db.from('profiles').upsert(_profileToDb(p));
  }

  @override
  Future<void> deleteProfile(String id) async {
    await _db.from('profiles').delete().eq('id', id);
  }

  @override
  Future<void> saveCampaign(Campaign c) async {
    await _db.from('campaigns').upsert(_campaignToDb(c));
  }

  @override
  Future<void> deleteCampaign(String id) async {
    await _db.from('campaigns').delete().eq('id', id);
  }

  @override
  Future<void> saveSwipe(Swipe s) async {
    await _db.from('swipes').upsert(
          _swipeToDb(s),
          onConflict: 'from_id,target_type,target_id',
        );
  }

  // ─────────────── Мапперы БД → модель и обратно ───────────────
  Profile _profileFromDb(Map<String, dynamic> j) => Profile(
        id: j['id'] as String,
        email: j['email'] as String? ?? '',
        password: '',
        role: j['role'] as String? ?? '',
        name: j['name'] as String? ?? '',
        avatarUrl: j['avatar_url'] as String? ?? '',
        bio: j['bio'] as String? ?? '',
        category: j['category'] as String? ?? '',
        location: j['location'] as String? ?? '',
        platform: j['platform'] as String? ?? '',
        followers: (j['followers'] as num?)?.toInt() ?? 0,
        engagement: (j['engagement'] as num?)?.toDouble() ?? 0,
        isBlocked: j['is_blocked'] as bool? ?? false,
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> _profileToDb(Profile p) => {
        'id': p.id,
        'email': p.email,
        'role': p.role,
        'name': p.name,
        'avatar_url': p.avatarUrl,
        'bio': p.bio,
        'category': p.category,
        'location': p.location,
        'platform': p.platform,
        'followers': p.followers,
        'engagement': p.engagement,
        'is_blocked': p.isBlocked,
      };

  Campaign _campaignFromDb(Map<String, dynamic> j) => Campaign(
        id: j['id'] as String,
        brandId: j['brand_id'] as String,
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        budget: (j['budget'] as num?)?.toInt() ?? 0,
        category: j['category'] as String? ?? '',
        imageUrl: j['image_url'] as String? ?? '',
        status: j['status'] as String? ?? 'active',
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> _campaignToDb(Campaign c) => {
        'id': c.id,
        'brand_id': c.brandId,
        'title': c.title,
        'description': c.description,
        'budget': c.budget,
        'category': c.category,
        'image_url': c.imageUrl,
        'status': c.status,
      };

  Swipe _swipeFromDb(Map<String, dynamic> j) => Swipe(
        id: j['id'] as String,
        fromId: j['from_id'] as String,
        targetType: j['target_type'] as String,
        targetId: j['target_id'] as String,
        liked: j['liked'] as bool? ?? false,
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> _swipeToDb(Swipe s) => {
        'from_id': s.fromId,
        'target_type': s.targetType,
        'target_id': s.targetId,
        'liked': s.liked,
      };
}
