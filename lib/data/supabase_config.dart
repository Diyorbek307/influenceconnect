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

  // Значения можно переопределить через --dart-define при сборке,
  // иначе используются рабочие ключи проекта (публичный ключ безопасен).
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://uauegllvjsvctwfziukb.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_RJQuIUhnsdDa2fnRus9WDg_HyeAlRbO',
  );

  /// Включён ли облачный бэкенд.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
