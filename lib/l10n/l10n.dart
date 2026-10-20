import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Простая локализация на 3 языка: узбекский, русский, английский.
/// Является [ChangeNotifier] — при смене языка весь интерфейс перестраивается.
class L10n extends ChangeNotifier {
  L10n._();
  static final L10n instance = L10n._();

  static const _kKey = 'ic_lang';
  static const codes = ['uz', 'ru', 'en'];
  static const names = {'uz': 'O‘zbekcha', 'ru': 'Русский', 'en': 'English'};

  String _code = 'ru';
  SharedPreferences? _prefs;

  String get code => _code;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs?.getString(_kKey);
    if (saved != null && codes.contains(saved)) _code = saved;
  }

  Future<void> setCode(String code) async {
    if (!codes.contains(code) || code == _code) return;
    _code = code;
    await _prefs?.setString(_kKey, code);
    notifyListeners();
  }

  /// Перевод по ключу. Возвращает строку текущего языка (fallback — ru).
  static String t(String key) {
    final row = _strings[key];
    if (row == null) return key;
    return row[instance._code] ?? row['ru'] ?? key;
  }

  static const Map<String, Map<String, String>> _strings = {
    // ── Онбординг ──
    'onb1_title': {'uz': 'Xush kelibsiz', 'ru': 'Добро пожаловать', 'en': 'Welcome'},
    'onb1_desc': {
      'uz': 'InfluenceConnect — brendlar va blogerlar reklama hamkorligi uchun bir-birini topadigan platforma.',
      'ru': 'InfluenceConnect — платформа, где бренды и блогеры находят друг друга для рекламных коллабораций.',
      'en': 'InfluenceConnect — a platform where brands and bloggers find each other for ad collaborations.'
    },
    'onb2_title': {'uz': 'Suring va tanlang', 'ru': 'Свайпай и выбирай', 'en': 'Swipe and choose'},
    'onb2_desc': {
      'uz': 'Brendlar blogerlarni, blogerlar kampaniyalarni suradi. Yoqsa — like, mos kelmasa — o‘tkazib yuboring.',
      'ru': 'Бренды листают блогеров, блогеры — кампании. Нравится — лайк, не подходит — пропуск.',
      'en': 'Brands browse bloggers, bloggers browse campaigns. Like it — swipe right, skip otherwise.'
    },
    'onb3_title': {'uz': 'Mosliklarni toping', 'ru': 'Находи совпадения', 'en': 'Find matches'},
    'onb3_desc': {
      'uz': 'Qiziqish o‘zaro bo‘lsa — moslik paydo bo‘ladi va hamkorlikni boshlash mumkin.',
      'ru': 'Когда интерес взаимный — появляется совпадение, и можно начинать сотрудничество.',
      'en': 'When interest is mutual — a match appears and you can start collaborating.'
    },
    'skip': {'uz': 'O‘tkazib yuborish', 'ru': 'Пропустить', 'en': 'Skip'},
    'next': {'uz': 'Keyingi', 'ru': 'Далее', 'en': 'Next'},
    'start': {'uz': 'Boshlash', 'ru': 'Начать', 'en': 'Get started'},

    // ── Выбор роли ──
    'who_are_you': {'uz': 'Siz kimsiz?', 'ru': 'Кто вы?', 'en': 'Who are you?'},
    'choose_role': {
      'uz': 'Rolni tanlang — kerakli funksiyalarni ko‘rsatamiz.',
      'ru': 'Выберите роль — так мы покажем нужные функции.',
      'en': 'Choose your role — we’ll show the right features.'
    },
    'brand': {'uz': 'Brend', 'ru': 'Бренд', 'en': 'Brand'},
    'blogger': {'uz': 'Bloger', 'ru': 'Блогер', 'en': 'Blogger'},
    'brand_desc': {
      'uz': 'Blogerlarni qidiraman, reklama kampaniyalari yarataman, ijrochilarni topaman.',
      'ru': 'Ищу блогеров, создаю рекламные кампании, нахожу исполнителей.',
      'en': 'I look for bloggers, create ad campaigns, find creators.'
    },
    'blogger_desc': {
      'uz': 'Reklama kampaniyalarini topaman, javob beraman va hamkorlikdan daromad qilaman.',
      'ru': 'Нахожу рекламные кампании, откликаюсь и зарабатываю на коллаборациях.',
      'en': 'I find ad campaigns, apply and earn from collaborations.'
    },
    'admin_login': {'uz': 'Administrator kirishi', 'ru': 'Вход для администратора', 'en': 'Admin login'},
    'language': {'uz': 'Til', 'ru': 'Язык', 'en': 'Language'},

    // ── Вход / регистрация ──
    'welcome_back': {'uz': 'Qaytganingiz bilan 👋', 'ru': 'С возвращением 👋', 'en': 'Welcome back 👋'},
    'login_sub': {'uz': 'Davom etish uchun kiring', 'ru': 'Войдите, чтобы продолжить', 'en': 'Sign in to continue'},
    'email': {'uz': 'Email', 'ru': 'Email', 'en': 'Email'},
    'password': {'uz': 'Parol', 'ru': 'Пароль', 'en': 'Password'},
    'password_repeat': {'uz': 'Parolni takrorlang', 'ru': 'Повторите пароль', 'en': 'Repeat password'},
    'login': {'uz': 'Kirish', 'ru': 'Войти', 'en': 'Sign in'},
    'no_account': {'uz': 'Akkaunt yo‘qmi?', 'ru': 'Нет аккаунта?', 'en': 'No account?'},
    'register': {'uz': 'Ro‘yxatdan o‘tish', 'ru': 'Зарегистрироваться', 'en': 'Sign up'},
    'create_account': {'uz': 'Akkaunt yaratish', 'ru': 'Создать аккаунт', 'en': 'Create account'},
    'have_account': {'uz': 'Akkaunt bormi?', 'ru': 'Уже есть аккаунт?', 'en': 'Have an account?'},
    'invite_code': {'uz': 'Taklif kodi (ixtiyoriy)', 'ru': 'Код-приглашение (необязательно)', 'en': 'Invite code (optional)'},

    // ── Навигация ──
    'nav_search': {'uz': 'Qidiruv', 'ru': 'Поиск', 'en': 'Search'},
    'nav_campaigns': {'uz': 'Kampaniyalar', 'ru': 'Кампании', 'en': 'Campaigns'},
    'nav_matches': {'uz': 'Mosliklar', 'ru': 'Совпадения', 'en': 'Matches'},
    'nav_chats': {'uz': 'Chatlar', 'ru': 'Чаты', 'en': 'Chats'},
    'nav_profile': {'uz': 'Profil', 'ru': 'Профиль', 'en': 'Profile'},
    'nav_requests': {'uz': 'So‘rovlar', 'ru': 'Запросы', 'en': 'Requests'},
    'nav_dashboard': {'uz': 'Boshqaruv', 'ru': 'Дашборд', 'en': 'Dashboard'},
    'nav_users': {'uz': 'Foydalanuvchilar', 'ru': 'Пользователи', 'en': 'Users'},

    // ── Заголовки ──
    'title_find_bloggers': {'uz': 'Blogerlarni qidirish', 'ru': 'Поиск блогеров', 'en': 'Find bloggers'},
    'title_my_campaigns': {'uz': 'Mening kampaniyalarim', 'ru': 'Мои кампании', 'en': 'My campaigns'},
    'title_messages': {'uz': 'Xabarlar', 'ru': 'Сообщения', 'en': 'Messages'},
    'title_admin': {'uz': 'Admin', 'ru': 'Админ', 'en': 'Admin'},

    // ── Общее / кнопки ──
    'save': {'uz': 'Saqlash', 'ru': 'Сохранить', 'en': 'Save'},
    'refresh': {'uz': 'Yangilash', 'ru': 'Обновить', 'en': 'Refresh'},
    'edit_profile': {'uz': 'Profilni tahrirlash', 'ru': 'Редактировать профиль', 'en': 'Edit profile'},
    'logout': {'uz': 'Chiqish', 'ru': 'Выйти', 'en': 'Log out'},
    'logout_q': {'uz': 'Akkauntdan chiqasizmi?', 'ru': 'Выйти из аккаунта?', 'en': 'Log out?'},
    'cancel': {'uz': 'Bekor qilish', 'ru': 'Отмена', 'en': 'Cancel'},
    'delete': {'uz': 'O‘chirish', 'ru': 'Удалить', 'en': 'Delete'},
    'create_campaign': {'uz': 'Kampaniya yaratish', 'ru': 'Создать кампанию', 'en': 'Create campaign'},
    'write_msg': {'uz': 'Yozish', 'ru': 'Написать', 'en': 'Message'},
    'all': {'uz': 'Barchasi', 'ru': 'Все', 'en': 'All'},
    'send_hint': {'uz': 'Xabar…', 'ru': 'Сообщение…', 'en': 'Message…'},
    'about_me': {'uz': 'O‘zim haqimda', 'ru': 'О себе', 'en': 'About'},
    'city': {'uz': 'Shahar', 'ru': 'Город', 'en': 'City'},
    'followers': {'uz': 'Obunachilar', 'ru': 'Подписчики', 'en': 'Followers'},
    'engagement': {'uz': 'Faollik', 'ru': 'Вовлечённость', 'en': 'Engagement'},

    // ── Пустые состояния ──
    'empty_matches_t': {'uz': 'Hali mosliklar yo‘q', 'ru': 'Пока нет совпадений', 'en': 'No matches yet'},
    'empty_matches_s': {
      'uz': 'Siz va bloger o‘zaro qiziqish bildirsangiz, moslik paydo bo‘ladi.',
      'ru': 'Мэтч появится, когда вы и блогер проявите взаимный интерес.',
      'en': 'A match appears when you and a blogger show mutual interest.'
    },
    'empty_chats_t': {'uz': 'Hali xabarlar yo‘q', 'ru': 'Пока нет сообщений', 'en': 'No messages yet'},
    'empty_chats_s': {
      'uz': 'Moslikdan so‘ng bu yerda suhbatlar paydo bo‘ladi.',
      'ru': 'Диалоги появятся здесь после совпадения с брендом или блогером.',
      'en': 'Conversations will appear here after a match.'
    },

    // ── Кампании (форма) ──
    'campaign_new': {'uz': 'Yangi kampaniya', 'ru': 'Новая кампания', 'en': 'New campaign'},
    'campaign_edit': {'uz': 'Kampaniyani tahrirlash', 'ru': 'Редактировать кампанию', 'en': 'Edit campaign'},
    'field_title': {'uz': 'Nomi', 'ru': 'Название', 'en': 'Title'},
    'field_description': {'uz': 'Tavsif', 'ru': 'Описание', 'en': 'Description'},
    'field_budget': {'uz': 'Byudjet, ₽', 'ru': 'Бюджет, ₽', 'en': 'Budget, ₽'},
    'field_category': {'uz': 'Kategoriya', 'ru': 'Категория', 'en': 'Category'},
    'field_industry': {'uz': 'Soha', 'ru': 'Индустрия', 'en': 'Industry'},
    'field_niche': {'uz': 'Yo‘nalish', 'ru': 'Ниша', 'en': 'Niche'},
    'field_platform': {'uz': 'Platforma', 'ru': 'Платформа', 'en': 'Platform'},
    'field_name_blogger': {'uz': 'Ism / taxallus', 'ru': 'Имя / псевдоним', 'en': 'Name / nickname'},
    'field_name_brand': {'uz': 'Brend nomi', 'ru': 'Название бренда', 'en': 'Brand name'},
    'field_followers': {'uz': 'Obunachilar soni', 'ru': 'Число подписчиков', 'en': 'Followers count'},
    'field_engagement': {'uz': 'Faollik (ER), %', 'ru': 'Вовлечённость (ER), %', 'en': 'Engagement (ER), %'},

    // ── Валидация ──
    'val_title': {'uz': 'Nomini kiriting', 'ru': 'Введите название', 'en': 'Enter a title'},
    'val_desc': {'uz': 'Vazifani batafsilroq yozing (10+ belgi)', 'ru': 'Опишите задачу подробнее (от 10 символов)', 'en': 'Describe in more detail (10+ chars)'},
    'val_budget': {'uz': 'Byudjet summasini kiriting', 'ru': 'Введите сумму бюджета', 'en': 'Enter the budget amount'},
    'val_email': {'uz': 'Email kiriting', 'ru': 'Введите email', 'en': 'Enter email'},
    'val_password': {'uz': 'Parolni kiriting', 'ru': 'Введите пароль', 'en': 'Enter password'},
    'val_pass_min': {'uz': 'Kamida 6 ta belgi', 'ru': 'Минимум 6 символов', 'en': 'At least 6 characters'},
    'val_pass_match': {'uz': 'Parollar mos emas', 'ru': 'Пароли не совпадают', 'en': 'Passwords don’t match'},
    'val_name': {'uz': 'Ismni kiriting', 'ru': 'Укажите имя', 'en': 'Enter a name'},

    // ── Статусы / меню ──
    'status_active': {'uz': 'Faol', 'ru': 'Активна', 'en': 'Active'},
    'status_pending': {'uz': 'Moderatsiyada', 'ru': 'На модерации', 'en': 'Under review'},
    'status_closed': {'uz': 'Yopiq', 'ru': 'Закрыта', 'en': 'Closed'},
    'menu_open': {'uz': 'Ochish', 'ru': 'Открыть', 'en': 'Open'},
    'menu_edit': {'uz': 'Tahrirlash', 'ru': 'Редактировать', 'en': 'Edit'},
    'menu_close': {'uz': 'Yopish', 'ru': 'Закрыть', 'en': 'Close'},
    'menu_activate': {'uz': 'Faollashtirish', 'ru': 'Активировать', 'en': 'Activate'},
    'block': {'uz': 'Bloklash', 'ru': 'Заблокировать', 'en': 'Block'},
    'unblock': {'uz': 'Blokdan chiqarish', 'ru': 'Разблокировать', 'en': 'Unblock'},
    'blocked': {'uz': 'Bloklangan', 'ru': 'Заблокирован', 'en': 'Blocked'},
    'campaign_one': {'uz': 'Kampaniya', 'ru': 'Кампания', 'en': 'Campaign'},

    // ── Кампании бренда ──
    'no_campaigns_t': {'uz': 'Hali kampaniyalar yo‘q', 'ru': 'У вас пока нет кампаний', 'en': 'No campaigns yet'},
    'no_campaigns_s': {'uz': 'Blogerlar javob berishi uchun birinchi kampaniyani yarating.', 'ru': 'Создайте первую кампанию, чтобы блогеры могли откликнуться.', 'en': 'Create your first campaign so bloggers can apply.'},
    'delete_campaign_q': {'uz': 'Kampaniya o‘chirilsinmi?', 'ru': 'Удалить кампанию?', 'en': 'Delete campaign?'},
    'delete_user_q': {'uz': 'Foydalanuvchi o‘chirilsinmi?', 'ru': 'Удалить пользователя?', 'en': 'Delete user?'},
    'deleted': {'uz': 'O‘chirildi', 'ru': 'Удалено', 'en': 'Deleted'},
    'saved': {'uz': 'Saqlandi', 'ru': 'Сохранено', 'en': 'Saved'},
    'responses': {'uz': 'Javoblar', 'ru': 'Отклики', 'en': 'Responses'},
    'favorites': {'uz': 'Saralangan', 'ru': 'Избранное', 'en': 'Favorites'},
    'no_responses_t': {'uz': 'Hali javoblar yo‘q', 'ru': 'Пока нет откликов', 'en': 'No responses yet'},
    'interest_brands': {'uz': 'Brendlar qiziqishi', 'ru': 'Интерес брендов', 'en': 'Brand interest'},
    'my_responses': {'uz': 'Mening javoblarim', 'ru': 'Мои отклики', 'en': 'My responses'},

    // ── Чат ──
    'chat_start_t': {'uz': 'Suhbatni boshlang', 'ru': 'Начните переписку', 'en': 'Start a conversation'},
    'chat_start_s': {'uz': 'Hamkorlikni kelishish uchun birinchi xabarni yozing.', 'ru': 'Напишите первое сообщение, чтобы договориться о коллаборации.', 'en': 'Send the first message to arrange a collaboration.'},
    'you_prefix': {'uz': 'Siz: ', 'ru': 'Вы: ', 'en': 'You: '},
    'no_messages': {'uz': 'Xabarlar yo‘q', 'ru': 'Нет сообщений', 'en': 'No messages'},
    'chat': {'uz': 'Chat', 'ru': 'Чат', 'en': 'Chat'},

    // ── Админ ──
    'total_users': {'uz': 'Jami foydalanuvchilar', 'ru': 'Всего пользователей', 'en': 'Total users'},
    'metrics': {'uz': 'Ko‘rsatkichlar', 'ru': 'Метрики', 'en': 'Metrics'},
    'brands': {'uz': 'Brendlar', 'ru': 'Бренды', 'en': 'Brands'},
    'bloggers': {'uz': 'Blogerlar', 'ru': 'Блогеры', 'en': 'Bloggers'},
    'active': {'uz': 'Faol', 'ru': 'Активные', 'en': 'Active'},
    'likes': {'uz': 'Layklar', 'ru': 'Лайки', 'en': 'Likes'},
    'blocked_count': {'uz': 'Bloklangan', 'ru': 'Заблокировано', 'en': 'Blocked'},
    'search_user': {'uz': 'Ism yoki email bo‘yicha qidirish', 'ru': 'Поиск по имени или email', 'en': 'Search by name or email'},
    'no_role': {'uz': 'Rolsiz', 'ru': 'Без роли', 'en': 'No role'},
    'nobody_found': {'uz': 'Hech kim topilmadi', 'ru': 'Никого не найдено', 'en': 'Nobody found'},
    'no_campaigns_admin_t': {'uz': 'Kampaniyalar yo‘q', 'ru': 'Кампаний нет', 'en': 'No campaigns'},

    // ── Прочее ──
    'applied': {'uz': 'Javob berdi', 'ru': 'Откликнулся', 'en': 'Applied'},
    'interest_sent': {'uz': 'qiziqish yuborildi', 'ru': 'интерес отправлен', 'en': 'interest sent'},
    'you_applied': {'uz': 'Siz javob berdingiz', 'ru': 'Вы откликнулись', 'en': 'You applied'},
    'profile_not_found': {'uz': 'Profil topilmadi', 'ru': 'Профиль не найден', 'en': 'Profile not found'},
    'about_blogger': {'uz': 'Bloger haqida', 'ru': 'О блогере', 'en': 'About the blogger'},
    'no_bio': {'uz': 'Tavsif to‘ldirilmagan.', 'ru': 'Описание не заполнено.', 'en': 'No description provided.'},

    // ── Пустые ленты / свайп ──
    'all_viewed_bloggers': {'uz': 'Barcha blogerlarni ko‘rib chiqdingiz', 'ru': 'Вы просмотрели всех блогеров', 'en': 'You’ve viewed all bloggers'},
    'no_bloggers_niche': {'uz': 'Bu yo‘nalishda bloger yo‘q', 'ru': 'В этой нише блогеров нет', 'en': 'No bloggers in this niche'},
    'change_filter_matches': {'uz': 'Filtrni o‘zgartiring yoki «Mosliklar»ga kiring.', 'ru': 'Смените фильтр или загляните в «Совпадения».', 'en': 'Change the filter or check “Matches”.'},
    'no_new_campaigns': {'uz': 'Yangi kampaniyalar yo‘q', 'ru': 'Новых кампаний нет', 'en': 'No new campaigns'},
    'no_campaigns_cat': {'uz': 'Bu kategoriyada kampaniya yo‘q', 'ru': 'В этой категории кампаний нет', 'en': 'No campaigns in this category'},
    'change_filter_requests': {'uz': 'Filtrni o‘zgartiring yoki «So‘rovlar»ni tekshiring.', 'ru': 'Смените фильтр или проверьте раздел «Запросы».', 'en': 'Change the filter or check “Requests”.'},
    'saved_female': {'uz': 'saqlandi', 'ru': 'сохранён(а)', 'en': 'saved'},
    'you_responded': {'uz': 'siz javob berdingiz', 'ru': 'вы откликнулись на', 'en': 'you applied to'},
    'nothing_liked': {'uz': 'Hali hech narsa yoqtirilmagan', 'ru': 'Пока ничего не понравилось', 'en': 'Nothing liked yet'},
  };
}

/// Короткий помощник: tr('key').
String tr(String key) => L10n.t(key);
