import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/campaign.dart';
import '../models/message.dart';
import '../models/profile.dart';
import '../models/swipe.dart';
import '../utils/iterable_ext.dart';
import 'data_source.dart';
import 'seed_data.dart';

/// Локальный источник данных (демо-режим): всё хранится в SharedPreferences,
/// при первом запуске наполняется демо-базой.
class LocalDataSource implements DataSource {
  static const _kProfiles = 'ic_profiles';
  static const _kCampaigns = 'ic_campaigns';
  static const _kSwipes = 'ic_swipes';
  static const _kMessages = 'ic_messages';
  static const _kCurrentUser = 'ic_current_user';

  SharedPreferences? _prefs;
  final List<Profile> _profiles = [];
  final List<Campaign> _campaigns = [];
  final List<Swipe> _swipes = [];
  final List<Message> _messages = [];
  String? _currentUserId;
  int _counter = 0;

  @override
  Future<void> init() async {
    final prefs = _prefs = await SharedPreferences.getInstance();

    final rawProfiles = prefs.getString(_kProfiles);
    if (rawProfiles == null) {
      _profiles.addAll(SeedData.profiles());
      _campaigns.addAll(SeedData.campaigns());
      await _persist();
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
      final rawMessages = prefs.getString(_kMessages);
      if (rawMessages != null) {
        _messages
          ..clear()
          ..addAll((jsonDecode(rawMessages) as List)
              .map((e) => Message.fromJson(e as Map<String, dynamic>)));
      }
    }
    _currentUserId = prefs.getString(_kCurrentUser);
  }

  Future<void> _persist() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(
        _kProfiles, jsonEncode(_profiles.map((e) => e.toJson()).toList()));
    await prefs.setString(
        _kCampaigns, jsonEncode(_campaigns.map((e) => e.toJson()).toList()));
    await prefs.setString(
        _kSwipes, jsonEncode(_swipes.map((e) => e.toJson()).toList()));
    await prefs.setString(
        _kMessages, jsonEncode(_messages.map((e) => e.toJson()).toList()));
  }

  String _newId(String prefix) {
    _counter++;
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$_counter';
  }

  @override
  String? currentUserId() => _currentUserId;

  @override
  Future<String> register({
    required String email,
    required String password,
    required bool asAdmin,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (_profiles.any((p) => p.email.toLowerCase() == normalized)) {
      throw AppException('Пользователь с таким email уже существует.');
    }
    final profile = Profile(
      id: _newId('user'),
      email: normalized,
      password: password,
      role: asAdmin ? 'admin' : '',
      name: asAdmin ? 'Администратор' : '',
      avatarUrl: 'https://i.pravatar.cc/400?u=$normalized',
      createdAt: DateTime.now(),
    );
    _profiles.add(profile);
    _currentUserId = profile.id;
    await _prefs?.setString(_kCurrentUser, profile.id);
    await _persist();
    return profile.id;
  }

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    final profile =
        _profiles.where((p) => p.email.toLowerCase() == normalized).firstOrNull;
    if (profile == null || profile.password != password) {
      throw AppException('Неверный email или пароль.');
    }
    if (profile.isBlocked) {
      throw AppException('Аккаунт заблокирован администратором.');
    }
    _currentUserId = profile.id;
    await _prefs?.setString(_kCurrentUser, profile.id);
    return profile.id;
  }

  @override
  Future<void> logout() async {
    _currentUserId = null;
    await _prefs?.remove(_kCurrentUser);
  }

  @override
  Future<List<Profile>> fetchProfiles() async =>
      _profiles.map((e) => Profile.fromJson(e.toJson())).toList();

  @override
  Future<List<Campaign>> fetchCampaigns() async =>
      _campaigns.map((e) => Campaign.fromJson(e.toJson())).toList();

  @override
  Future<List<Swipe>> fetchSwipes() async =>
      _swipes.map((e) => Swipe.fromJson(e.toJson())).toList();

  @override
  Future<void> saveProfile(Profile profile) async {
    final i = _profiles.indexWhere((p) => p.id == profile.id);
    if (i >= 0) {
      _profiles[i] = profile;
    } else {
      _profiles.add(profile);
    }
    await _persist();
  }

  @override
  Future<void> deleteProfile(String id) async {
    _profiles.removeWhere((p) => p.id == id);
    _campaigns.removeWhere((c) => c.brandId == id);
    _swipes.removeWhere((s) => s.fromId == id || s.targetId == id);
    await _persist();
  }

  @override
  Future<void> saveCampaign(Campaign campaign) async {
    final i = _campaigns.indexWhere((c) => c.id == campaign.id);
    if (i >= 0) {
      _campaigns[i] = campaign;
    } else {
      _campaigns.add(campaign);
    }
    await _persist();
  }

  @override
  Future<void> deleteCampaign(String id) async {
    _campaigns.removeWhere((c) => c.id == id);
    _swipes.removeWhere((s) => s.targetType == 'campaign' && s.targetId == id);
    await _persist();
  }

  @override
  Future<void> saveSwipe(Swipe swipe) async {
    _swipes.removeWhere((s) =>
        s.fromId == swipe.fromId &&
        s.targetType == swipe.targetType &&
        s.targetId == swipe.targetId);
    _swipes.add(swipe);
    await _persist();
  }

  @override
  Future<List<Message>> fetchMessages() async =>
      _messages.map((e) => Message.fromJson(e.toJson())).toList();

  @override
  Future<void> saveMessage(Message message) async {
    _messages.add(message);
    await _persist();
  }
}
