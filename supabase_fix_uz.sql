-- ============================================================================
-- Исправление демо-блогеров в облаке: русские описания, города (Ташкент),
-- реальные фото. Выполнить в Supabase → SQL Editor → Run.
-- ============================================================================
update public.profiles set location='Ташкент',  bio='Бьюти-блогер: обзоры косметики, уход за кожей, уроки макияжа.',   avatar_url='https://randomuser.me/api/portraits/women/44.jpg' where email='dilnoza@uz.demo';
update public.profiles set location='Ташкент',  bio='Обзоры техники: смартфоны, ноутбуки, гаджеты простым языком.',    avatar_url='https://randomuser.me/api/portraits/men/32.jpg'   where email='jasur@uz.demo';
update public.profiles set location='Самарканд', bio='Рецепты национальных и современных блюд. Готовим легко.',         avatar_url='https://randomuser.me/api/portraits/women/68.jpg' where email='aziza@uz.demo';
update public.profiles set location='Ташкент',  bio='Юмористические скетчи и вайны. Каждый день — порция смеха.',       avatar_url='https://randomuser.me/api/portraits/men/45.jpg'   where email='bekzod@uz.demo';
update public.profiles set location='Ташкент',  bio='Стилист: образы, тренды, подбор повседневной одежды.',            avatar_url='https://randomuser.me/api/portraits/women/12.jpg' where email='madina@uz.demo';
update public.profiles set location='Бухара',   bio='Путешествия по Узбекистану: маршруты, места, лайфхаки.',          avatar_url='https://randomuser.me/api/portraits/men/76.jpg'   where email='sardor@uz.demo';
update public.profiles set location='Ташкент',  bio='Фитнес-тренер: домашние тренировки, ЗОЖ, мотивация.',             avatar_url='https://randomuser.me/api/portraits/women/33.jpg' where email='nilufar@uz.demo';
update public.profiles set location='Фергана',  bio='Стримы и обзоры игр, киберспорт, гайды.',                         avatar_url='https://randomuser.me/api/portraits/men/51.jpg'   where email='shohruh@uz.demo';
update public.profiles set location='Наманган', bio='Блог о повседневной жизни: быт, продуктивность, уют.',            avatar_url='https://randomuser.me/api/portraits/women/90.jpg' where email='kamola@uz.demo';
update public.profiles set location='Ташкент',  bio='Личные финансы, инвестиции для начинающих.',                      avatar_url='https://randomuser.me/api/portraits/men/19.jpg'   where email='otabek@uz.demo';
update public.profiles set location='Андижан',  bio='Мама двоих: развитие детей, обзоры товаров для малышей.',         avatar_url='https://randomuser.me/api/portraits/women/57.jpg' where email='zarina@uz.demo';
update public.profiles set location='Ташкент',  bio='Тест-драйвы, ремонт, помощь в подборе авто.',                     avatar_url='https://randomuser.me/api/portraits/men/8.jpg'    where email='islom@uz.demo';
update public.profiles set location='Ташкент',  bio='Учу английскому легко: лайфхаки, разбор ошибок.',                 avatar_url='https://randomuser.me/api/portraits/women/25.jpg' where email='gulnora@uz.demo';
update public.profiles set location='Хива',     bio='Музыкант и продюсер: каверы, биты, жизнь за кулисами студии.',    avatar_url='https://randomuser.me/api/portraits/men/64.jpg'   where email='davron@uz.demo';
