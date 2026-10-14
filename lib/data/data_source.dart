import '../models/campaign.dart';
import '../models/profile.dart';
import '../models/swipe.dart';

/// Исключение уровня бизнес-логики (понятный текст для UI).
class AppException implements Exception {
  final String message;
  AppException(this.message);
  @override
  String toString() => message;
}

/// Абстракция источника данных. Скрывает, где лежат данные — локально
/// (SharedPreferences) или в облаке (Supabase). [AppRepository] держит кэш
/// и всю логику выборок, а сюда делегирует аутентификацию и хранение.
abstract class DataSource {
  Future<void> init();

  /// id текущего авторизованного пользователя (или null).
  String? currentUserId();

  /// Регистрация. Возвращает id созданного пользователя.
  Future<String> register({
    required String email,
    required String password,
    required bool asAdmin,
  });

  /// Вход. Возвращает id пользователя.
  Future<String> login({required String email, required String password});

  Future<void> logout();

  Future<List<Profile>> fetchProfiles();
  Future<List<Campaign>> fetchCampaigns();
  Future<List<Swipe>> fetchSwipes();

  Future<void> saveProfile(Profile profile);
  Future<void> deleteProfile(String id);

  Future<void> saveCampaign(Campaign campaign);
  Future<void> deleteCampaign(String id);

  Future<void> saveSwipe(Swipe swipe);
}
