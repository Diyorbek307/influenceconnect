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

  static String _avatar(String seed) =>
      'https://i.pravatar.cc/400?u=${Uri.encodeComponent(seed)}';

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
          id: 'b_anna',
          name: 'Анна Соколова',
          category: 'Красота',
          platform: 'Instagram',
          followers: 428000,
          engagement: 4.8,
          location: 'Москва',
          bio: 'Бьюти-блогер. Обзоры косметики, макияж, уход за кожей. Честные рекомендации.',
        ),
        _blogger(
          id: 'b_maxim',
          name: 'Максим Орлов',
          category: 'Технологии',
          platform: 'YouTube',
          followers: 1250000,
          engagement: 3.1,
          location: 'Санкт-Петербург',
          bio: 'Распаковки гаджетов, обзоры смартфонов и ноутбуков. Техника простым языком.',
        ),
        _blogger(
          id: 'b_dasha',
          name: 'Дарья Ким',
          category: 'Фитнес',
          platform: 'Instagram',
          followers: 86000,
          engagement: 7.4,
          location: 'Казань',
          bio: 'Тренер. Домашние тренировки, ЗОЖ, мотивация. Помогаю прийти в форму.',
        ),
        _blogger(
          id: 'b_timur',
          name: 'Тимур Рахимов',
          category: 'Еда',
          platform: 'TikTok',
          followers: 540000,
          engagement: 9.2,
          location: 'Ташкент',
          bio: 'Рецепты за 60 секунд. Уличная еда, домашняя кухня, обзоры заведений.',
        ),
        _blogger(
          id: 'b_lena',
          name: 'Елена Морозова',
          category: 'Путешествия',
          platform: 'Instagram',
          followers: 312000,
          engagement: 5.3,
          location: 'Сочи',
          bio: 'Путешествую по миру бюджетно. Маршруты, лайфхаки, красивые места.',
        ),
        _blogger(
          id: 'b_kirill',
          name: 'Кирилл Жуков',
          category: 'Игры',
          platform: 'YouTube',
          followers: 920000,
          engagement: 6.1,
          location: 'Новосибирск',
          bio: 'Стримы и обзоры игр, киберспорт, гайды. Крупнейшее гейм-комьюнити региона.',
        ),
        _blogger(
          id: 'b_sofia',
          name: 'София Белова',
          category: 'Мода',
          platform: 'Instagram',
          followers: 198000,
          engagement: 5.9,
          location: 'Москва',
          bio: 'Стилист. Образы, тренды, разборы гардероба. Мода без лишних трат.',
        ),
        _blogger(
          id: 'b_denis',
          name: 'Денис Волков',
          category: 'Юмор',
          platform: 'TikTok',
          followers: 2100000,
          engagement: 11.5,
          location: 'Екатеринбург',
          bio: 'Скетчи и вайны. Делаю людей счастливее каждый день.',
        ),
        _blogger(
          id: 'b_marina',
          name: 'Марина Цой',
          category: 'Лайфстайл',
          platform: 'Instagram',
          followers: 64000,
          engagement: 8.1,
          location: 'Владивосток',
          bio: 'Дневник обычной жизни: быт, продуктивность, уют. Тёплый микро-блог.',
        ),
        _blogger(
          id: 'b_artem',
          name: 'Артём Лебедев',
          category: 'Финансы',
          platform: 'YouTube',
          followers: 410000,
          engagement: 4.2,
          location: 'Москва',
          bio: 'Личные финансы, инвестиции для новичков, разбор привычек с деньгами.',
        ),
        _blogger(
          id: 'b_nika',
          name: 'Ника Романова',
          category: 'Материнство',
          platform: 'Instagram',
          followers: 155000,
          engagement: 6.7,
          location: 'Краснодар',
          bio: 'Мама двоих. Развитие детей, товары для малышей, честные отзывы.',
        ),
        _blogger(
          id: 'b_pavel',
          name: 'Павел Громов',
          category: 'Авто',
          platform: 'YouTube',
          followers: 735000,
          engagement: 4.9,
          location: 'Тольятти',
          bio: 'Тест-драйвы, ремонт, автоподбор. Всё про машины честно и по делу.',
        ),
        _blogger(
          id: 'b_vika',
          name: 'Виктория Нгуен',
          category: 'Образование',
          platform: 'TikTok',
          followers: 288000,
          engagement: 7.8,
          location: 'Минск',
          bio: 'Учу английскому легко. Лайфхаки, разговорные фразы, разбор ошибок.',
        ),
        _blogger(
          id: 'b_oleg',
          name: 'Олег Соловьёв',
          category: 'Музыка',
          platform: 'Instagram',
          followers: 47000,
          engagement: 9.6,
          location: 'Казань',
          bio: 'Музыкант и продюсер. Каверы, биты, закулисье студии. Растущий nano-блог.',
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
