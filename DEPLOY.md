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

## 3. База данных (общая для всех) — Supabase (бесплатно)

Код уже готов к Supabase: приложение само переключается на облако, если заданы
ключи (`SUPABASE_URL` + `SUPABASE_ANON_KEY`). Без ключей работает локальный
демо-режим. Нужно создать проект и один раз выполнить SQL.

1. Зайди на https://supabase.com → **New project** (бесплатно).
   В **Settings → API** скопируй **Project URL** и **anon/publishable key**.
2. **SQL Editor** → выполни по очереди:
   - [`supabase_schema.sql`](supabase_schema.sql) — таблицы, связи, права (RLS), триггер.
   - [`supabase_seed.sql`](supabase_seed.sql) — наполнение базы блогерами/брендами/кампаниями.
3. **Authentication → Providers → Email** → **выключи «Confirm email»**
   (чтобы вход работал сразу после регистрации, без подтверждения почты).
4. Включи ключи в приложении — одним из способов:
   - **На Render:** сервис → **Environment** → добавь `SUPABASE_URL` и
     `SUPABASE_ANON_KEY` → **Manual Deploy / Save**. Render пересоберёт сайт уже с облаком.
   - **Локально:**
     ```bash
     flutter run -d chrome \
       --dart-define=SUPABASE_URL=ТВОЙ_URL \
       --dart-define=SUPABASE_ANON_KEY=ТВОЙ_KEY
     ```
5. Зарегистрируй свой аккаунт в приложении, затем в SQL Editor назначь себя админом:
   ```sql
   update public.profiles set role = 'admin' where email = 'ТВОЙ_EMAIL';
   ```

> Можешь просто прислать мне **Project URL** и **anon key** — я проверю
> подключение и всё дотюню.

> Примечание: кнопки «быстрого входа» (демо-аккаунты) на экране входа
> работают только в локальном режиме. В облаке вход — через реальную
> регистрацию; витринные блогеры из `supabase_seed.sql` показываются в ленте.

> Альтернатива — Postgres прямо на Render, но к нему нельзя безопасно
> обращаться из браузера без отдельного backend-сервера, поэтому для
> клиентского Flutter-приложения Supabase проще и тоже бесплатен.
