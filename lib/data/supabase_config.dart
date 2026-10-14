/// Настройки подключения к Supabase.
///
/// Чтобы включить общую облачную базу данных:
/// 1. Создайте бесплатный проект на https://supabase.com
/// 2. Settings → API: скопируйте Project URL и anon public key
/// 3. Вставьте их ниже (или передайте через --dart-define при сборке)
///
/// Пока значения пустые — приложение работает на локальном бэкенде (демо).
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Включён ли облачный бэкенд.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
