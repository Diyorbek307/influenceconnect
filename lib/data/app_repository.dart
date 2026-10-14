import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/campaign.dart';
import '../models/profile.dart';
import '../models/swipe.dart';
import '../utils/iterable_ext.dart';
import '../utils/uuid.dart';
import 'data_source.dart';
import 'local_data_source.dart';
import 'seed_data.dart';
import 'supabase_config.dart';
import 'supabase_data_source.dart';

export 'data_source.dart' show AppException;

/// Главный репозиторий приложения: держит кэш данных в памяти и всю логику
/// выборок, а хранение/аутентификацию делегирует [DataSource]
/// (локальный демо-режим или Supabase — выбирается автоматически).
///
/// Является [ChangeNotifier] — экраны подписываются через [ListenableBuilder].
class AppRepository extends ChangeNotifier {
  AppRepository._();
  static final AppRepository instance = AppRepository._();

  static const _kOnboarding = 'ic_onboarding_seen';

  late DataSource _ds;
  SharedPreferences? _prefs;

  final List<Profile> _profiles = [];
  final List<Campaign> _campaigns = [];
  final List<Swipe> _swipes = [];

  Profile? _currentUser;
  bool _onboardingSeen = false;

  /// Используется ли облачный бэкенд (Supabase).
  bool get isCloud => SupabaseConfig.isConfigured;

  // ─────────────────────────── Геттеры ───────────────────────────
  Profile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get onboardingSeen => _onboardingSeen;

  List<Profile> get allProfiles => List.unmodifiable(_profiles);
  List<Campaign> get allCampaigns => List.unmodifiable(_campaigns);

  List<Profile> get bloggers => _profiles.where((p) => p.isBlogger).toList();
  List<Profile> get brands => _profiles.where((p) => p.isBrand).toList();

  // ─────────────────────────── Инициализация ───────────────────────────
  /// [dataSource] можно передать в тестах, чтобы форсировать локальный источник.
  Future<void> init({DataSource? dataSource}) async {
    _ds = dataSource ??
        (SupabaseConfig.isConfigured ? SupabaseDataSource() : LocalDataSource());
    await _ds.init();

    _prefs = await SharedPreferences.getInstance();
    _onboardingSeen = _prefs?.getBool(_kOnboarding) ?? false;

    await _reload();
    _resolveCurrentUser();
  }

  Future<void> _reload() async {
    final profiles = await _ds.fetchProfiles();
    final campaigns = await _ds.fetchCampaigns();
    final swipes = await _ds.fetchSwipes();
    _profiles
      ..clear()
      ..addAll(profiles);
    _campaigns
      ..clear()
      ..addAll(campaigns);
    _swipes
      ..clear()
      ..addAll(swipes);
  }

  void _resolveCurrentUser() {
    final id = _ds.currentUserId();
    _currentUser = id == null ? null : _profiles.where((p) => p.id == id).firstOrNull;
  }

  Future<void> markOnboardingSeen() async {
    _onboardingSeen = true;
    await _prefs?.setBool(_kOnboarding, true);
  }

  Profile? profileById(String id) =>
      _profiles.where((p) => p.id == id).firstOrNull;

  // ─────────────────────────── Аутентификация ───────────────────────────
  Future<Profile> register({
    required String email,
    required String password,
    String inviteCode = '',
  }) async {
    final normalized = email.trim().toLowerCase();
    if (!_isValidEmail(normalized)) {
      throw AppException('Введите корректный email.');
    }
    if (password.length < 6) {
      throw AppException('Пароль должен быть не короче 6 символов.');
    }
    final asAdmin = inviteCode.trim() == _adminInviteCode;

    await _ds.register(email: normalized, password: password, asAdmin: asAdmin);
    await _reload();
    _resolveCurrentUser();
    if (_currentUser == null) {
      throw AppException('Не удалось войти после регистрации.');
    }
    notifyListeners();
    return _currentUser!;
  }

  Future<Profile> login({required String email, required String password}) async {
    await _ds.login(email: email, password: password);
    await _reload();
    _resolveCurrentUser();
    if (_currentUser == null) {
      throw AppException('Профиль не найден.');
    }
    notifyListeners();
    return _currentUser!;
  }

  Future<void> logout() async {
    await _ds.logout();
    _currentUser = null;
    notifyListeners();
  }

  /// Вход по выбору роли без регистрации: логинится в демо-аккаунт роли,
  /// а если его ещё нет — создаёт на лету.
  Future<void> enterAsRole(String role) async {
    final email = role == 'brand'
        ? SeedData.entryBrandEmail
        : SeedData.entryBloggerEmail;
    const pass = SeedData.entryPassword;
    try {
      await _ds.login(email: email, password: pass);
    } on AppException {
      await _ds.register(email: email, password: pass, asAdmin: false);
    }
    await _reload();
    _resolveCurrentUser();
    final u = _currentUser;
    if (u == null) throw AppException('Не удалось войти.');
    if (u.role != role) {
      u.role = role;
      if (u.name.isEmpty) {
        u.name = role == 'brand' ? 'Демо Бренд' : 'Демо Блогер';
      }
      if (role == 'blogger' && u.category.isEmpty) {
        u.category = 'Лайфстайл';
        u.platform = 'Instagram';
      }
      await _ds.saveProfile(u);
    }
    notifyListeners();
  }

  Future<void> selectRole(String role) async {
    final user = _currentUser;
    if (user == null) throw AppException('Нет активного пользователя.');
    user.role = role;
    await _ds.saveProfile(user);
    notifyListeners();
  }

  Future<void> updateCurrentProfile({
    String? name,
    String? bio,
    String? category,
    String? location,
    String? platform,
    int? followers,
    double? engagement,
    String? avatarUrl,
  }) async {
    final user = _currentUser;
    if (user == null) throw AppException('Нет активного пользователя.');
    if (name != null) user.name = name;
    if (bio != null) user.bio = bio;
    if (category != null) user.category = category;
    if (location != null) user.location = location;
    if (platform != null) user.platform = platform;
    if (followers != null) user.followers = followers;
    if (engagement != null) user.engagement = engagement;
    if (avatarUrl != null) user.avatarUrl = avatarUrl;
    await _ds.saveProfile(user);
    notifyListeners();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(email);

  String get _adminInviteCode => 'INFLUENCE-ADMIN';

  // ─────────────────────────── Кампании ───────────────────────────
  List<Campaign> campaignsByBrand(String brandId) =>
      _campaigns.where((c) => c.brandId == brandId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<Campaign> createCampaign({
    required String brandId,
    required String title,
    required String description,
    required int budget,
    required String category,
    required String imageUrl,
  }) async {
    final campaign = Campaign(
      id: Uuid.v4(),
      brandId: brandId,
      title: title,
      description: description,
      budget: budget,
      category: category,
      imageUrl: imageUrl.isEmpty
          ? 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/900/700'
          : imageUrl,
      status: 'active',
      createdAt: DateTime.now(),
    );
    await _ds.saveCampaign(campaign);
    _campaigns.add(campaign);
    notifyListeners();
    return campaign;
  }

  Future<void> updateCampaign(
    String id, {
    String? title,
    String? description,
    int? budget,
    String? category,
    String? status,
  }) async {
    final c = _campaigns.where((e) => e.id == id).firstOrNull;
    if (c == null) return;
    if (title != null) c.title = title;
    if (description != null) c.description = description;
    if (budget != null) c.budget = budget;
    if (category != null) c.category = category;
    if (status != null) c.status = status;
    await _ds.saveCampaign(c);
    notifyListeners();
  }

  Future<void> deleteCampaign(String id) async {
    await _ds.deleteCampaign(id);
    _campaigns.removeWhere((c) => c.id == id);
    _swipes.removeWhere((s) => s.targetType == 'campaign' && s.targetId == id);
    notifyListeners();
  }

  Future<void> setCampaignStatus(String id, String status) =>
      updateCampaign(id, status: status);

  // ─────────────────────────── Свайпы ───────────────────────────
  bool hasSwiped(String fromId, String targetType, String targetId) =>
      _swipes.any((s) =>
          s.fromId == fromId && s.targetType == targetType && s.targetId == targetId);

  Future<void> swipe({
    required String fromId,
    required String targetType,
    required String targetId,
    required bool liked,
  }) async {
    final swipe = Swipe(
      id: Uuid.v4(),
      fromId: fromId,
      targetType: targetType,
      targetId: targetId,
      liked: liked,
      createdAt: DateTime.now(),
    );
    await _ds.saveSwipe(swipe);
    _swipes.removeWhere((s) =>
        s.fromId == fromId && s.targetType == targetType && s.targetId == targetId);
    _swipes.add(swipe);
    notifyListeners();
  }

  List<Profile> discoverBloggersFor(String brandId) {
    return bloggers.where((b) {
      if (b.isBlocked) return false;
      return !hasSwiped(brandId, 'blogger', b.id);
    }).toList()
      ..sort((a, b) => b.followers.compareTo(a.followers));
  }

  List<Campaign> discoverCampaignsFor(String bloggerId) {
    return _campaigns.where((c) {
      if (!c.isActive) return false;
      final brand = profileById(c.brandId);
      if (brand == null || brand.isBlocked) return false;
      return !hasSwiped(bloggerId, 'campaign', c.id);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Profile> likedBloggersBy(String brandId) {
    final ids = _swipes
        .where((s) => s.fromId == brandId && s.targetType == 'blogger' && s.liked)
        .map((s) => s.targetId)
        .toSet();
    return _profiles.where((p) => ids.contains(p.id)).toList();
  }

  List<Campaign> likedCampaignsBy(String bloggerId) {
    final ids = _swipes
        .where((s) => s.fromId == bloggerId && s.targetType == 'campaign' && s.liked)
        .map((s) => s.targetId)
        .toSet();
    return _campaigns.where((c) => ids.contains(c.id)).toList();
  }

  List<Profile> brandsInterestedIn(String bloggerId) {
    final ids = _swipes
        .where((s) => s.targetType == 'blogger' && s.targetId == bloggerId && s.liked)
        .map((s) => s.fromId)
        .toSet();
    return _profiles.where((p) => ids.contains(p.id) && !p.isBlocked).toList();
  }

  List<({Profile blogger, Campaign campaign})> applicationsForBrand(String brandId) {
    final myCampaignIds =
        _campaigns.where((c) => c.brandId == brandId).map((c) => c.id).toSet();
    final result = <({Profile blogger, Campaign campaign})>[];
    for (final s in _swipes) {
      if (s.targetType == 'campaign' && s.liked && myCampaignIds.contains(s.targetId)) {
        final blogger = profileById(s.fromId);
        final campaign = _campaigns.where((c) => c.id == s.targetId).firstOrNull;
        if (blogger != null && campaign != null && !blogger.isBlocked) {
          result.add((blogger: blogger, campaign: campaign));
        }
      }
    }
    return result;
  }

  List<({Profile blogger, Campaign campaign})> matchesForBrand(String brandId) {
    final likedBloggerIds = likedBloggersBy(brandId).map((b) => b.id).toSet();
    return applicationsForBrand(brandId)
        .where((a) => likedBloggerIds.contains(a.blogger.id))
        .toList();
  }

  List<({Profile brand, Campaign campaign})> matchesForBlogger(String bloggerId) {
    final likedCampaigns = likedCampaignsBy(bloggerId);
    final result = <({Profile brand, Campaign campaign})>[];
    for (final c in likedCampaigns) {
      final brandLiked = _swipes.any((s) =>
          s.fromId == c.brandId &&
          s.targetType == 'blogger' &&
          s.targetId == bloggerId &&
          s.liked);
      if (brandLiked) {
        final brand = profileById(c.brandId);
        if (brand != null && !brand.isBlocked) {
          result.add((brand: brand, campaign: c));
        }
      }
    }
    return result;
  }

  // ─────────────────────────── Админ ───────────────────────────
  Future<void> setBlocked(String profileId, bool blocked) async {
    final p = profileById(profileId);
    if (p == null) return;
    p.isBlocked = blocked;
    await _ds.saveProfile(p);
    if (blocked && _currentUser?.id == profileId) {
      await logout();
      return;
    }
    notifyListeners();
  }

  Future<void> deleteProfile(String profileId) async {
    await _ds.deleteProfile(profileId);
    _profiles.removeWhere((p) => p.id == profileId);
    _campaigns.removeWhere((c) => c.brandId == profileId);
    _swipes.removeWhere((s) => s.fromId == profileId || s.targetId == profileId);
    notifyListeners();
  }

  AdminStats get adminStats {
    final activeCampaigns = _campaigns.where((c) => c.isActive).length;
    final likes = _swipes.where((s) => s.liked).length;
    int matches = 0;
    for (final brand in brands) {
      matches += matchesForBrand(brand.id).length;
    }
    return AdminStats(
      brands: brands.length,
      bloggers: bloggers.length,
      campaigns: _campaigns.length,
      activeCampaigns: activeCampaigns,
      likes: likes,
      matches: matches,
      blocked: _profiles.where((p) => p.isBlocked).length,
    );
  }

  /// Принудительно перезагрузить кэш из источника (pull-to-refresh и т.п.).
  Future<void> refresh() async {
    await _reload();
    _resolveCurrentUser();
    notifyListeners();
  }
}

class AdminStats {
  final int brands;
  final int bloggers;
  final int campaigns;
  final int activeCampaigns;
  final int likes;
  final int matches;
  final int blocked;

  const AdminStats({
    required this.brands,
    required this.bloggers,
    required this.campaigns,
    required this.activeCampaigns,
    required this.likes,
    required this.matches,
    required this.blocked,
  });

  int get totalUsers => brands + bloggers;
}
