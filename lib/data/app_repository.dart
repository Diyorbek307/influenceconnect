import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/campaign.dart';
import '../models/profile.dart';
import '../models/swipe.dart';
import '../utils/iterable_ext.dart';
import 'seed_data.dart';

/// Исключение уровня бизнес-логики (понятный текст для UI).
class AppException implements Exception {
  final String message;
  AppException(this.message);
  @override
  String toString() => message;
}

/// Локальный бэкенд приложения (демо-режим).
///
/// Хранит пользователей, кампании и свайпы в памяти и сохраняет их на
/// устройстве через SharedPreferences. Является [ChangeNotifier] — экраны
/// подписываются через [ListenableBuilder] и обновляются автоматически.
///
/// Архитектура специально изолирует данные за одним классом: чтобы перейти
/// на Supabase, достаточно заменить реализацию этих же методов.
class AppRepository extends ChangeNotifier {
  AppRepository._();
  static final AppRepository instance = AppRepository._();

  static const _kProfiles = 'ic_profiles';
  static const _kCampaigns = 'ic_campaigns';
  static const _kSwipes = 'ic_swipes';
  static const _kCurrentUser = 'ic_current_user';
  static const _kOnboarding = 'ic_onboarding_seen';

  SharedPreferences? _prefs;
  final List<Profile> _profiles = [];
  final List<Campaign> _campaigns = [];
  final List<Swipe> _swipes = [];

  Profile? _currentUser;
  bool _onboardingSeen = false;
  int _idCounter = 0;

  // ─────────────────────────── Геттеры ───────────────────────────
  Profile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get onboardingSeen => _onboardingSeen;

  List<Profile> get allProfiles => List.unmodifiable(_profiles);
  List<Campaign> get allCampaigns => List.unmodifiable(_campaigns);

  List<Profile> get bloggers =>
      _profiles.where((p) => p.isBlogger).toList();
  List<Profile> get brands => _profiles.where((p) => p.isBrand).toList();

  String _newId(String prefix) {
    _idCounter++;
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }

  // ─────────────────────────── Инициализация ───────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final prefs = _prefs!;

    _onboardingSeen = prefs.getBool(_kOnboarding) ?? false;

    final rawProfiles = prefs.getString(_kProfiles);
    if (rawProfiles == null) {
      // Первый запуск — наполняем демо-базой.
      _profiles.addAll(SeedData.profiles());
      _campaigns.addAll(SeedData.campaigns());
      await _saveAll();
    } else {
      _profiles
        ..clear()
        ..addAll((jsonDecode(rawProfiles) as List)
            .map((e) => Profile.fromJson(e as Map<String, dynamic>)));

      final rawCampaigns = prefs.getString(_kCampaigns);
      if (rawCampaigns != null) {
        _campaigns
          ..clear()
          ..addAll((jsonDecode(rawCampaigns) as List)
              .map((e) => Campaign.fromJson(e as Map<String, dynamic>)));
      }
      final rawSwipes = prefs.getString(_kSwipes);
      if (rawSwipes != null) {
        _swipes
          ..clear()
          ..addAll((jsonDecode(rawSwipes) as List)
              .map((e) => Swipe.fromJson(e as Map<String, dynamic>)));
      }
    }

    final currentId = prefs.getString(_kCurrentUser);
    if (currentId != null) {
      _currentUser = _profiles.where((p) => p.id == currentId).firstOrNull;
    }
  }

  Future<void> _saveProfiles() async =>
      _prefs?.setString(_kProfiles, jsonEncode(_profiles.map((e) => e.toJson()).toList()));
  Future<void> _saveCampaigns() async =>
      _prefs?.setString(_kCampaigns, jsonEncode(_campaigns.map((e) => e.toJson()).toList()));
  Future<void> _saveSwipes() async =>
      _prefs?.setString(_kSwipes, jsonEncode(_swipes.map((e) => e.toJson()).toList()));

  Future<void> _saveAll() async {
    await _saveProfiles();
    await _saveCampaigns();
    await _saveSwipes();
  }

  Future<void> markOnboardingSeen() async {
    _onboardingSeen = true;
    await _prefs?.setBool(_kOnboarding, true);
  }

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
    if (_profiles.any((p) => p.email.toLowerCase() == normalized)) {
      throw AppException('Пользователь с таким email уже существует.');
    }

    final isAdmin = inviteCode.trim() == SeedData.adminInviteCode;

    final profile = Profile(
      id: _newId('user'),
      email: normalized,
      password: password,
      role: isAdmin ? 'admin' : '',
      name: isAdmin ? 'Администратор' : '',
      avatarUrl: 'https://i.pravatar.cc/400?u=$normalized',
      createdAt: DateTime.now(),
    );

    _profiles.add(profile);
    _currentUser = profile;
    await _saveProfiles();
    await _prefs?.setString(_kCurrentUser, profile.id);
    notifyListeners();
    return profile;
  }

  Future<Profile> login({required String email, required String password}) async {
    final normalized = email.trim().toLowerCase();
    final profile = _profiles
        .where((p) => p.email.toLowerCase() == normalized)
        .firstOrNull;

    if (profile == null || profile.password != password) {
      throw AppException('Неверный email или пароль.');
    }
    if (profile.isBlocked) {
      throw AppException('Аккаунт заблокирован администратором.');
    }

    _currentUser = profile;
    await _prefs?.setString(_kCurrentUser, profile.id);
    notifyListeners();
    return profile;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _prefs?.remove(_kCurrentUser);
    notifyListeners();
  }

  Future<void> selectRole(String role) async {
    final user = _currentUser;
    if (user == null) throw AppException('Нет активного пользователя.');
    user.role = role;
    await _saveProfiles();
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
    await _saveProfiles();
    notifyListeners();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(email);

  Profile? profileById(String id) =>
      _profiles.where((p) => p.id == id).firstOrNull;

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
      id: _newId('camp'),
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
    _campaigns.add(campaign);
    await _saveCampaigns();
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
    await _saveCampaigns();
    notifyListeners();
  }

  Future<void> deleteCampaign(String id) async {
    _campaigns.removeWhere((c) => c.id == id);
    _swipes.removeWhere((s) => s.targetType == 'campaign' && s.targetId == id);
    await _saveCampaigns();
    await _saveSwipes();
    notifyListeners();
  }

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
    _swipes.removeWhere((s) =>
        s.fromId == fromId && s.targetType == targetType && s.targetId == targetId);
    _swipes.add(Swipe(
      id: _newId('swipe'),
      fromId: fromId,
      targetType: targetType,
      targetId: targetId,
      liked: liked,
      createdAt: DateTime.now(),
    ));
    await _saveSwipes();
    notifyListeners();
  }

  // ── Лента для бренда: блогеры, которых ещё не свайпали ──
  List<Profile> discoverBloggersFor(String brandId) {
    return bloggers.where((b) {
      if (b.isBlocked) return false;
      return !hasSwiped(brandId, 'blogger', b.id);
    }).toList()
      ..sort((a, b) => b.followers.compareTo(a.followers));
  }

  // ── Лента для блогера: активные кампании, которые ещё не свайпали ──
  List<Campaign> discoverCampaignsFor(String bloggerId) {
    return _campaigns.where((c) {
      if (!c.isActive) return false;
      final brand = profileById(c.brandId);
      if (brand == null || brand.isBlocked) return false;
      return !hasSwiped(bloggerId, 'campaign', c.id);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Блогеры, которых бренд лайкнул (сохранил).
  List<Profile> likedBloggersBy(String brandId) {
    final ids = _swipes
        .where((s) => s.fromId == brandId && s.targetType == 'blogger' && s.liked)
        .map((s) => s.targetId)
        .toSet();
    return _profiles.where((p) => ids.contains(p.id)).toList();
  }

  /// Кампании, которые лайкнул (откликнулся) блогер.
  List<Campaign> likedCampaignsBy(String bloggerId) {
    final ids = _swipes
        .where((s) => s.fromId == bloggerId && s.targetType == 'campaign' && s.liked)
        .map((s) => s.targetId)
        .toSet();
    return _campaigns.where((c) => ids.contains(c.id)).toList();
  }

  /// Бренды, которые проявили интерес к блогеру (лайкнули его).
  List<Profile> brandsInterestedIn(String bloggerId) {
    final ids = _swipes
        .where((s) => s.targetType == 'blogger' && s.targetId == bloggerId && s.liked)
        .map((s) => s.fromId)
        .toSet();
    return _profiles.where((p) => ids.contains(p.id) && !p.isBlocked).toList();
  }

  /// Отклики блогеров на кампании бренда: пары (блогер, кампания).
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

  /// Взаимные совпадения для бренда: бренд лайкнул блогера И блогер
  /// откликнулся хотя бы на одну кампанию этого бренда.
  List<({Profile blogger, Campaign campaign})> matchesForBrand(String brandId) {
    final likedBloggerIds = likedBloggersBy(brandId).map((b) => b.id).toSet();
    return applicationsForBrand(brandId)
        .where((a) => likedBloggerIds.contains(a.blogger.id))
        .toList();
  }

  /// Взаимные совпадения для блогера.
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
    if (blocked && _currentUser?.id == profileId) {
      await logout();
    }
    await _saveProfiles();
    notifyListeners();
  }

  Future<void> deleteProfile(String profileId) async {
    _profiles.removeWhere((p) => p.id == profileId);
    _campaigns.removeWhere((c) => c.brandId == profileId);
    _swipes.removeWhere((s) => s.fromId == profileId || s.targetId == profileId);
    await _saveAll();
    notifyListeners();
  }

  Future<void> setCampaignStatus(String id, String status) =>
      updateCampaign(id, status: status);

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

  /// Полный сброс базы к демо-состоянию (для отладки).
  Future<void> resetToSeed() async {
    _profiles
      ..clear()
      ..addAll(SeedData.profiles());
    _campaigns
      ..clear()
      ..addAll(SeedData.campaigns());
    _swipes.clear();
    _currentUser = null;
    await _saveAll();
    await _prefs?.remove(_kCurrentUser);
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
