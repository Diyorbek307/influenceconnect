# Публикация: Git → Render (бесплатно) → База данных

Ниже — пошагово. Шаги 1 и 3 требуют твоих аккаунтов (GitHub, Render,
по желанию Supabase) — их за тебя выполнить нельзя, но всё подготовлено.

---

## 1. Git + GitHub

Локальный репозиторий уже инициализирован и закоммичен (ветка `main`).
Осталось создать пустой репозиторий на GitHub и запушить.

1. Зайди на https://github.com/new → создай репозиторий
   (например `influenceconnect`), **без** README/лицензии/`.gitignore`.
2. Подключи его как remote и запушь (подставь свой логин):

```bash
git remote add origin https://github.com/ТВОЙ_ЛОГИН/influenceconnect.git
git branch -M main
git push -u origin main
```

> Если при push попросит логин/пароль — пароль это **Personal Access Token**
> (GitHub → Settings → Developer settings → Tokens), а не пароль от аккаунта.

---

## 2. Render — бесплатный статический сайт (Flutter Web)

Файл [`render.yaml`](render.yaml) уже в репозитории — Render подхватит его сам.

1. Зайди на https://render.com → **Get Started** (вход через GitHub — бесплатно).
2. **New** → **Blueprint** → выбери свой репозиторий `influenceconnect`.
3. Render прочитает `render.yaml`, покажет сервис `influenceconnect`
   (тип **Static Site**, план **Free**) → **Apply**.
4. Первая сборка идёт ~5–10 минут (Render скачивает Flutter SDK и собирает web).
5. Готово: сайт будет доступен по адресу вида
   `https://influenceconnect.onrender.com`.

> Статический сайт на Render бесплатен и не «засыпает».
> При каждом `git push` в `main` Render пересобирает сайт автоматически.

Проверить сборку локально можно так:
```bash
flutter build web --release   # результат в build/web
```

---

## 3. База данных (общая для всех пользователей) — Supabase (бесплатно)

Сейчас приложение использует **локальный бэкенд**: оно работает сразу и
на деплое, но данные хранятся в браузере каждого пользователя отдельно.
Чтобы данные были **общими** (все видят одни и те же профили/кампании),
нужна серверная БД. Самый простой бесплатный вариант для Flutter — Supabase.

1. Зайди на https://supabase.com → создай бесплатный проект
   (запомни **Project URL** и **anon public key** из Settings → API).
2. Открой **SQL Editor** → вставь целиком [`supabase_schema.sql`](supabase_schema.sql)
   → **Run**. Это создаст таблицы, связи и права (RLS).
3. Зарегистрируй свой аккаунт в приложении, затем в SQL Editor выполни:
   ```sql
   update public.profiles set role = 'admin' where email = 'ТВОЙ_EMAIL';
   ```
4. Дай знать — я подключу приложение к Supabase: добавлю SDK и переключу
   `AppRepository` на сервер (вся логика уже изолирована в одном классе,
   поэтому правок немного). После этого `git push` → Render пересоберёт сайт.

> Альтернатива — Postgres прямо на Render, но к нему нельзя безопасно
> обращаться из браузера без отдельного backend-сервера, поэтому для
> клиентского Flutter-приложения Supabase проще и тоже бесплатен.
