import '../models/campaign.dart';
import '../models/profile.dart';

/// Демо-наполнение «временной базы»: реалистичные блогеры разных ниш,
/// бренды с кампаниями и аккаунт администратора.
///
/// Пароль для всех демо-аккаунтов: demo1234 (у администратора — admin123).
/// Данные блогеров смоделированы по реальным тирам охвата и вовлечённости
/// (nano/micro/mid/macro) и типичным нишам инфлюенс-маркетинга.
class SeedData {
  SeedData._();

  static const String demoPassword = 'demo1234';
  static const String adminPassword = 'admin123';
  static const String adminEmail = 'admin@influence.app';

  /// Секретное слово: при вводе в поле «код-приглашение» на регистрации
  /// аккаунт сразу становится администратором.
  static const String adminInviteCode = 'INFLUENCE-ADMIN';

  // Аккаунты для входа по выбору роли (без регистрации).
  static const String entryBrandEmail = 'brand@influence.app';
  static const String entryBloggerEmail = 'blogger@influence.app';
  static const String entryPassword = 'demo12345';

  /// Реальные портреты для блогеров (надёжный CDN randomuser.me);
  /// для остальных — pravatar по сиду.
  static const Map<String, String> _portraits = {
    'b_dilnoza': 'women/44',
    'b_jasur': 'men/32',
    'b_aziza': 'women/68',
    'b_bekzod': 'men/45',
    'b_madina': 'women/12',
    'b_sardor': 'men/76',
    'b_nilufar': 'women/33',
    'b_shohruh': 'men/51',
    'b_kamola': 'women/90',
    'b_otabek': 'men/19',
    'b_zarina': 'women/57',
    'b_islom': 'men/8',
    'b_gulnora': 'women/25',
    'b_davron': 'men/64',
  };

  static String _avatar(String seed) {
    final p = _portraits[seed];
    if (p != null) return 'https://randomuser.me/api/portraits/$p.jpg';
    return 'https://i.pravatar.cc/400?u=${Uri.encodeComponent(seed)}';
  }

  static String _cover(String seed) =>
      'https://picsum.photos/seed/${Uri.encodeComponent(seed)}/900/700';

  static DateTime _daysAgo(int d) => DateTime.now().subtract(Duration(days: d));

  static Profile _blogger({
    required String id,
    required String name,
    required String category,
    required String platform,
    required int followers,
    required double engagement,
    required String location,
    required String bio,
  }) {
    return Profile(
      id: id,
      email: '${id.replaceAll('b_', '')}@demo.app',
      password: demoPassword,
      role: 'blogger',
      name: name,
      avatarUrl: _avatar(id),
      bio: bio,
      category: category,
      location: location,
      platform: platform,
      followers: followers,
      engagement: engagement,
      createdAt: _daysAgo(followers % 90 + 3),
    );
  }

  static List<Profile> profiles() => [
        // ───────── Администратор ─────────
        Profile(
          id: 'admin_1',
          email: adminEmail,
          password: adminPassword,
          role: 'admin',
          name: 'Администратор',
          avatarUrl: _avatar('admin_1'),
          bio: 'Модерация платформы InfluenceConnect.',
          location: 'Москва',
          createdAt: _daysAgo(200),
        ),

        // ───────── Блогеры ─────────
        _blogger(
          id: 'b_dilnoza',
          name: 'Dilnoza Karimova',
          category: 'Красота',
          platform: 'Instagram',
          followers: 385000,
          engagement: 5.2,
          location: 'Тошкент',
          bio: 'Go‘zallik blogeri. Kosmetika sharhlari, parvarish, makiyaj darslari.',
        ),
        _blogger(
          id: 'b_jasur',
          name: 'Jasur Umarov',
          category: 'Технологии',
          platform: 'YouTube',
          followers: 640000,
          engagement: 4.1,
          location: 'Тошкент',
          bio: 'Texnika sharhlari: smartfonlar, noutbuklar, gadjetlar oddiy tilda.',
        ),
        _blogger(
          id: 'b_aziza',
          name: 'Aziza Rashidova',
          category: 'Еда',
          platform: 'Instagram',
          followers: 274000,
          engagement: 6.8,
          location: 'Самарканд',
          bio: 'Milliy va zamonaviy taomlar retseptlari. Oson pishiriladigan ovqatlar.',
        ),
        _blogger(
          id: 'b_bekzod',
          name: 'Bekzod Toshmatov',
          category: 'Юмор',
          platform: 'TikTok',
          followers: 1450000,
          engagement: 10.3,
          location: 'Тошкент',
          bio: 'Hajviy sketchlar va vayn. Har kuni kulgi ulashaman.',
        ),
        _blogger(
          id: 'b_madina',
          name: 'Madina Yusupova',
          category: 'Мода',
          platform: 'Instagram',
          followers: 218000,
          engagement: 5.7,
          location: 'Тошкент',
          bio: 'Stilist. Obrazlar, trendlar, kundalik kiyim tanlash.',
        ),
        _blogger(
          id: 'b_sardor',
          name: 'Sardor Rahimov',
          category: 'Путешествия',
          platform: 'YouTube',
          followers: 330000,
          engagement: 4.9,
          location: 'Бухара',
          bio: 'O‘zbekiston bo‘ylab sayohat: marshrutlar, joylar, lifehaklar.',
        ),
        _blogger(
          id: 'b_nilufar',
          name: 'Nilufar Abdullayeva',
          category: 'Фитнес',
          platform: 'Instagram',
          followers: 97000,
          engagement: 7.6,
          location: 'Тошкент',
          bio: 'Fitnes murabbiy. Uyda mashqlar, sog‘lom turmush, motivatsiya.',
        ),
        _blogger(
          id: 'b_shohruh',
          name: 'Shohruh Mirzaev',
          category: 'Игры',
          platform: 'YouTube',
          followers: 505000,
          engagement: 6.2,
          location: 'Фергана',
          bio: 'O‘yin striml va sharhlar, kibersport, gaydlar.',
        ),
        _blogger(
          id: 'b_kamola',
          name: 'Kamola Sobirova',
          category: 'Лайфстайл',
          platform: 'Instagram',
          followers: 142000,
          engagement: 6.5,
          location: 'Наманган',
          bio: 'Kundalik hayot blogi: turmush, mahsuldorlik, qulaylik.',
        ),
        _blogger(
          id: 'b_otabek',
          name: 'Otabek Nazarov',
          category: 'Финансы',
          platform: 'Telegram',
          followers: 88000,
          engagement: 5.4,
          location: 'Тошкент',
          bio: 'Shaxsiy moliya, yangi boshlovchilar uchun investitsiyalar.',
        ),
        _blogger(
          id: 'b_zarina',
          name: 'Zarina Islomova',
          category: 'Материнство',
          platform: 'Instagram',
          followers: 176000,
          engagement: 7.1,
          location: 'Андижан',
          bio: 'Ikki farzand onasi. Bolalar rivoji, chaqaloq mahsulotlari sharhi.',
        ),
        _blogger(
          id: 'b_islom',
          name: 'Islom Qodirov',
          category: 'Авто',
          platform: 'YouTube',
          followers: 410000,
          engagement: 4.6,
          location: 'Тошкент',
          bio: 'Avtomobil test-drayvlar, ta’mirlash, avto tanlash bo‘yicha maslahatlar.',
        ),
        _blogger(
          id: 'b_gulnora',
          name: 'Gulnora Ergasheva',
          category: 'Образование',
          platform: 'TikTok',
          followers: 263000,
          engagement: 8.2,
          location: 'Тошкент',
          bio: 'Ingliz tilini oson o‘rgataman. Lifehaklar, xatolar tahlili.',
        ),
        _blogger(
          id: 'b_davron',
          name: 'Davron Saidov',
          category: 'Музыка',
          platform: 'Instagram',
          followers: 59000,
          engagement: 9.1,
          location: 'Хива',
          bio: 'Musiqachi va prodyuser. Kaverlar, bitlar, studiya ortidagi hayot.',
        ),

        // ───────── Бренды ─────────
        Profile(
          id: 'brand_glow',
          email: 'glow@demo.app',
          password: demoPassword,
          role: 'brand',
          name: 'GLOW Cosmetics',
          avatarUrl: _avatar('brand_glow'),
          bio: 'Корейская уходовая косметика. Ищем бьюти-блогеров для коллабораций.',
          category: 'Красота',
          location: 'Москва',
          createdAt: _daysAgo(120),
        ),
        Profile(
          id: 'brand_fit',
          email: 'fit@demo.app',
          password: demoPassword,
          role: 'brand',
          name: 'FitFuel',
          avatarUrl: _avatar('brand_fit'),
          bio: 'Спортивное питание и батончики. Партнёримся с фитнес-авторами.',
          category: 'Фитнес',
          location: 'Санкт-Петербург',
          createdAt: _daysAgo(95),
        ),
        Profile(
          id: 'brand_techno',
          email: 'techno@demo.app',
          password: demoPassword,
          role: 'brand',
          name: 'TechNova',
          avatarUrl: _avatar('brand_techno'),
          bio: 'Аксессуары для гаджетов. Нужны тех-обзорщики с лояльной аудиторией.',
          category: 'Технологии',
          location: 'Москва',
          createdAt: _daysAgo(60),
        ),
      ];

  static List<Campaign> campaigns() => [
        Campaign(
          id: 'c_glow_1',
          brandId: 'brand_glow',
          title: 'Запуск сыворотки GLOW Vitamin C',
          description:
              'Ищем 3 бьюти-блогеров для обзора новой сыворотки. Нужен честный отзыв, распаковка и сторис с промокодом. Бюджет за интеграцию.',
          budget: 45000,
          category: 'Красота',
          imageUrl: _cover('glow1'),
          status: 'active',
          createdAt: _daysAgo(8),
        ),
        Campaign(
          id: 'c_fit_1',
          brandId: 'brand_fit',
          title: 'Протеиновые батончики: 30-дневный челлендж',
          description:
              'Фитнес-авторы, запустите челлендж с нашими батончиками. Reels + сторис. Оплата + продукция на месяц.',
          budget: 60000,
          category: 'Фитнес',
          imageUrl: _cover('fit1'),
          status: 'active',
          createdAt: _daysAgo(5),
        ),
        Campaign(
          id: 'c_techno_1',
          brandId: 'brand_techno',
          title: 'Обзор беспроводной зарядки NovaPad',
          description:
              'Тех-обзорщики — нужен честный обзор зарядки на YouTube/TikTok. Присылаем девайс + гонорар.',
          budget: 80000,
          category: 'Технологии',
          imageUrl: _cover('techno1'),
          status: 'active',
          createdAt: _daysAgo(3),
        ),
        Campaign(
          id: 'c_glow_2',
          brandId: 'brand_glow',
          title: 'Коллаба к 8 марта: подарочные наборы',
          description:
              'Сезонная кампания. Распаковка подарочного набора и розыгрыш среди подписчиков.',
          budget: 35000,
          category: 'Красота',
          imageUrl: _cover('glow2'),
          status: 'active',
          createdAt: _daysAgo(1),
        ),
      ];
}
