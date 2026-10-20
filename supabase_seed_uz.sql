-- ============================================================================
-- InfluenceConnect — замена демо-блогеров на УЗБЕКСКИХ.
-- Выполнять в Supabase → SQL Editor → Run. Безопасно (идемпотентно).
-- Удаляет прежних демо-блогеров (email %@demo.app) и вставляет узбекских.
-- ============================================================================

-- 1) Убираем свайпы, указывающие на старых демо-блогеров
delete from public.swipes
where target_type = 'blogger'
  and target_id in (
    select id from public.profiles
    where role = 'blogger' and email like '%@demo.app'
  );

-- 2) Удаляем старых демо-блогеров
delete from public.profiles
where role = 'blogger' and email like '%@demo.app';

-- 3) Вставляем узбекских блогеров
insert into public.profiles
  (id, email, role, name, avatar_url, bio, category, location, platform, followers, engagement)
values
  ('44444444-4444-4444-8444-000000000001','dilnoza@uz.demo','blogger','Dilnoza Karimova','https://i.pravatar.cc/400?u=uz_dilnoza','Go''zallik blogeri. Kosmetika sharhlari, parvarish, makiyaj darslari.','Красота','Тошкент','Instagram',385000,5.2),
  ('44444444-4444-4444-8444-000000000002','jasur@uz.demo','blogger','Jasur Umarov','https://i.pravatar.cc/400?u=uz_jasur','Texnika sharhlari: smartfonlar, noutbuklar, gadjetlar oddiy tilda.','Технологии','Тошкент','YouTube',640000,4.1),
  ('44444444-4444-4444-8444-000000000003','aziza@uz.demo','blogger','Aziza Rashidova','https://i.pravatar.cc/400?u=uz_aziza','Milliy va zamonaviy taomlar retseptlari. Oson pishiriladigan ovqatlar.','Еда','Самарканд','Instagram',274000,6.8),
  ('44444444-4444-4444-8444-000000000004','bekzod@uz.demo','blogger','Bekzod Toshmatov','https://i.pravatar.cc/400?u=uz_bekzod','Hajviy sketchlar va vayn. Har kuni kulgi ulashaman.','Юмор','Тошкент','TikTok',1450000,10.3),
  ('44444444-4444-4444-8444-000000000005','madina@uz.demo','blogger','Madina Yusupova','https://i.pravatar.cc/400?u=uz_madina','Stilist. Obrazlar, trendlar, kundalik kiyim tanlash.','Мода','Тошкент','Instagram',218000,5.7),
  ('44444444-4444-4444-8444-000000000006','sardor@uz.demo','blogger','Sardor Rahimov','https://i.pravatar.cc/400?u=uz_sardor','O''zbekiston bo''ylab sayohat: marshrutlar, joylar, lifehaklar.','Путешествия','Бухара','YouTube',330000,4.9),
  ('44444444-4444-4444-8444-000000000007','nilufar@uz.demo','blogger','Nilufar Abdullayeva','https://i.pravatar.cc/400?u=uz_nilufar','Fitnes murabbiy. Uyda mashqlar, sog''lom turmush, motivatsiya.','Фитнес','Тошкент','Instagram',97000,7.6),
  ('44444444-4444-4444-8444-000000000008','shohruh@uz.demo','blogger','Shohruh Mirzaev','https://i.pravatar.cc/400?u=uz_shohruh','O''yin striml va sharhlar, kibersport, gaydlar.','Игры','Фергана','YouTube',505000,6.2),
  ('44444444-4444-4444-8444-000000000009','kamola@uz.demo','blogger','Kamola Sobirova','https://i.pravatar.cc/400?u=uz_kamola','Kundalik hayot blogi: turmush, mahsuldorlik, qulaylik.','Лайфстайл','Наманган','Instagram',142000,6.5),
  ('44444444-4444-4444-8444-00000000000a','otabek@uz.demo','blogger','Otabek Nazarov','https://i.pravatar.cc/400?u=uz_otabek','Shaxsiy moliya, yangi boshlovchilar uchun investitsiyalar.','Финансы','Тошкент','Telegram',88000,5.4),
  ('44444444-4444-4444-8444-00000000000b','zarina@uz.demo','blogger','Zarina Islomova','https://i.pravatar.cc/400?u=uz_zarina','Ikki farzand onasi. Bolalar rivoji, chaqaloq mahsulotlari sharhi.','Материнство','Андижан','Instagram',176000,7.1),
  ('44444444-4444-4444-8444-00000000000c','islom@uz.demo','blogger','Islom Qodirov','https://i.pravatar.cc/400?u=uz_islom','Avtomobil test-drayvlar, ta''mirlash, avto tanlash bo''yicha maslahatlar.','Авто','Тошкент','YouTube',410000,4.6),
  ('44444444-4444-4444-8444-00000000000d','gulnora@uz.demo','blogger','Gulnora Ergasheva','https://i.pravatar.cc/400?u=uz_gulnora','Ingliz tilini oson o''rgataman. Lifehaklar, xatolar tahlili.','Образование','Тошкент','TikTok',263000,8.2),
  ('44444444-4444-4444-8444-00000000000e','davron@uz.demo','blogger','Davron Saidov','https://i.pravatar.cc/400?u=uz_davron','Musiqachi va prodyuser. Kaverlar, bitlar, studiya ortidagi hayot.','Музыка','Хива','Instagram',59000,9.1)
on conflict (id) do nothing;
