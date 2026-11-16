# Success

A Flutter habit tracker with streaks, points and levels, and an AI assistant that can answer questions about your habits. Data lives in Supabase, or in a local SQLite database when Supabase is turned off.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Flutter](https://img.shields.io/badge/Flutter-Dart%203-02569B)

<!-- TODO: screenshots (habit list, progress dashboard, achievements, assistant chat) -->

## Features

- Create, edit and delete habits; mark daily completion.
- Progress dashboard with streaks (`streakBufferDays` allows a one-day buffer).
- Gamification: points, levels (100 points per level) and achievements.
- AI assistant chat with three interchangeable providers: Ollama (local), Google Gemini, or an OpenAI-compatible HTTP API. It can suggest habits from natural-language text, and the conversation is stored in the `assistant_conversations` table.
- Supabase backend with realtime subscriptions, so changes show up on other running instances.
- Optional local mode: set `USE_SUPABASE=false` to use SQLite (`sqflite`) instead.

## Architecture

```
lib/
  main.dart                       loads .env, initializes Supabase, runs the app
  core/config/app_config.dart     reads .env values
  core/database/                  models, SQLite helper, Supabase service
  features/
    habits/                       repository, list/detail pages, widgets
    progress/                     dashboard, streak widget
    gamification/                 repository, achievements/profile pages
    assistant/                    SLM service, providers (ollama, gemini, api), chat UI
database/                         supabase_setup.sql, enable_realtime.sql
tools/check_connections.dart      connectivity check for Ollama and Supabase
docs/                             setup guides
```

State management is Riverpod (`flutter_riverpod`). Configuration is loaded at startup with `flutter_dotenv`.

## Getting started

Prerequisites: Flutter SDK (Dart `>=3.0.0 <4.0.0`). Platform folders present in the repo: `android`, `linux`, `web`.

```bash
flutter pub get
cp .env.example .env     # .env is listed as a Flutter asset, so the file must exist
```

Edit `.env`. Variable names (see `.env.example`):

| Variable | Purpose |
|---|---|
| `SUPABASE_URL`, `SUPABASE_ANON_KEY` | Supabase project (Settings, API) |
| `USE_SUPABASE` | `true` (default) or `false` for local SQLite |
| `SLM_PROVIDER` | `ollama`, `gemini` or `api` |
| `OLLAMA_BASE_URL`, `OLLAMA_MODEL` | local Ollama |
| `GEMINI_API_KEY`, `GEMINI_MODEL` | Gemini |
| `API_BASE_URL`, `API_KEY` | OpenAI-compatible API |

Set up the database (skip if `USE_SUPABASE=false`): run `database/supabase_setup.sql`, then `database/enable_realtime.sql` in the Supabase SQL editor.

Run:

```bash
flutter run -d linux     # or: -d chrome, -d android
dart run tools/check_connections.dart   # optional connectivity check
```

More detail: [Supabase setup](docs/SUPABASE_SETUP.md), [AI providers](docs/AI_PROVIDER_SETUP.md), [Ollama](docs/OLLAMA_SETUP.md), [environment variables](docs/README_ENV.md), [realtime](docs/REALTIME_SETUP.md).

## Status and limitations

- Personal project, version 1.0.0. There are no automated tests.
- No user authentication: the app does not sign users in, and the SQL policies in `database/supabase_setup.sql` allow all operations to anyone holding the anon key. Use a private Supabase project and do not store sensitive data. Add auth and per-user policies before any shared deployment.
- `.env` is bundled as an asset, so any key in it ships inside the built app. Use a personal build only, and do not put paid API keys into builds you distribute.
- The leaderboard widget is a placeholder.
- Only `android`, `linux` and `web` platform folders exist; iOS, macOS and Windows would need `flutter create .`.

## License

MIT, see [LICENSE](LICENSE).
