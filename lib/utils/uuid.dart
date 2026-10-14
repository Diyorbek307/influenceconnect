import 'dart:math';

/// Генератор UUID v4 без внешних зависимостей.
/// Формат совместим с типом uuid в Postgres/Supabase.
class Uuid {
  Uuid._();
  static final Random _rnd = Random.secure();

  static String v4() {
    final b = List<int>.generate(16, (_) => _rnd.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40; // версия 4
    b[8] = (b[8] & 0x3f) | 0x80; // вариант
    String hex(int i) => b[i].toRadixString(16).padLeft(2, '0');
    final s = List.generate(16, hex).join();
    return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-'
        '${s.substring(16, 20)}-${s.substring(20)}';
  }
}
