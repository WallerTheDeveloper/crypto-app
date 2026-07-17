# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project

A cross-platform mobile crypto dashboard built with Flutter. Users track the market, hold a portfolio (with profit/loss), set price alerts, and view live prices. Target audience is general/balanced — readable, not pro-trader dense.

The Flutter app lives in `nova_project/` (this is the actual `flutter pub get` / `flutter run` root — not the repo root). `crypto-dashboard-flutter-design/` is a Claude-Design handoff bundle (HTML/CSS/JS prototype, not production code) — read `crypto-dashboard-flutter-design/README.md` and the linked `.dc.html` file for the intended visual design before building UI, and recreate it pixel-perfectly in Flutter rather than porting its markup.

## Locked technical decisions

Do not introduce alternatives to these without an explicit decision to change them.

- **Framework:** Flutter (Dart), stable channel. Targets iOS and Android.
- **State management:** Riverpod. Do not use Provider, Bloc, setState-for-shared-state, or InheritedWidget directly for app state.
- **Backend:** Firebase — Auth (login), Firestore (portfolio, alerts, user prefs), Cloud Messaging (push alerts), Cloud Functions (server-side price-threshold checks).
- **Market data:** CoinGecko (market list, coin detail, historical chart data).
- **Live prices:** Binance WebSocket (real-time ticker streams).
- **Charts:** fl_chart.
- **Local storage / offline cache:** Hive.

## Architecture

Feature-first with clean layering. SOLID is mandatory.

```
nova_project/lib/
  core/                 shared across features
    theme/              theme tokens, both themes, theme controller
    constants/
    utils/
    error/              failure types, error handling
    network/            shared http/websocket clients
  features/
    <feature>/
      data/             DTOs/models, remote/local data sources, repository IMPLEMENTATIONS
      domain/           entities, repository INTERFACES, use cases (pure Dart, no Flutter/Firebase imports)
      presentation/     screens, widgets, Riverpod providers/notifiers
  main.dart
```

### Layer rules (dependency direction)

- Dependencies point inward: `presentation` → `domain` ← `data`. `domain` depends on nothing else in the app.
- `domain` is pure Dart: no imports of Flutter, Firebase, http, Hive, or any package tied to a framework or data source.
- Repository **interfaces** live in `domain`; **implementations** live in `data`. Presentation depends on the interface, never the implementation (dependency inversion).
- Data sources (CoinGecko, Binance, Firestore, Hive) are only touched inside `data`. Never call an API, Firebase, or Hive from a widget or a Riverpod provider in `presentation`.
- Map external DTOs/models (`data`) to domain entities (`domain`) at the repository boundary. UI consumes entities, not raw API JSON or Firestore documents.

### SOLID application

- **Single responsibility:** a class does one thing. Data sources fetch, repositories coordinate + map, use cases hold business logic, notifiers hold UI state.
- **Open/closed + Liskov:** depend on repository interfaces so a data source can be swapped without changing callers.
- **Interface segregation:** keep interfaces small and purpose-specific.
- **Dependency inversion:** high-level code depends on abstractions; Riverpod providers supply the concrete implementations.

## State management (Riverpod) conventions

- Expose repositories, data sources, and use cases as providers so they can be overridden in tests.
- Use `AsyncNotifier` / `Notifier` (or `AsyncValue`) for screen state. Represent loading, data, and error explicitly via `AsyncValue` — do not hand-roll boolean flags for load/error state.
- Stream data (live prices, Firestore documents) is exposed through `StreamProvider` or async notifiers, never polled manually in widgets.
- Keep providers close to the feature they serve (`features/<feature>/presentation/`). Shared providers go in `core/`.
- Widgets read state; they do not fetch or compute business logic.

## Data layer rules

- Every remote call goes through a data source, then a repository, then (optionally) a use case, before reaching presentation.
- Cache-then-network: read from Hive for instant display, then refresh from the network and update. Cache the last successful response so screens degrade gracefully offline.
- Handle and type errors in the `data`/`domain` layers (return typed failures). Never let a raw exception surface to the UI unhandled.
- Respect API rate limits: build and rely on caching rather than hammering endpoints; debounce/refresh on sensible intervals.

## Design system rules

- Two themes exist: **Dark (vibrant accents)** and **Playful (warm)**. A user-facing toggle switches between them. Every screen must work in both.
- Theme token values live in `core/theme/` and are the source of truth for colors — reference tokens, never hardcode hex in features or widgets.
- **Semantic color separation (strict):** price up / profit uses the theme's `gain` token; price down / loss uses the `loss` token; the `accent` token is only for interactive elements (buttons, active tabs, selected states, primary chart line). Never use `accent` to encode price movement, and never use `gain`/`loss` for generic UI.
- The two themes are structurally identical: same layouts and spacing, only tokens differ. Do not fork layout per theme.
- Corner radius: cards `16`, controls/buttons `12`, pills/badges fully rounded. Two font weights only: 400 and 500. Sentence case in all UI copy.
- Every data-bound screen must implement four states: loading (skeleton shimmer), empty (designed and inviting), error (message + retry), and populated.
- The design handoff bundle (`crypto-dashboard-flutter-design/`) is the reference for visual design (exact layouts, spacing, colors as prototyped in HTML/CSS); this file is the reference for code conventions.

## Naming and file conventions

- Files: `snake_case.dart`. Classes/enums: `PascalCase`. Members/variables: `camelCase`.
- One primary public class per file; file name matches the class (`portfolio_repository.dart` → `PortfolioRepository`).
- Suffix by role: `*_screen.dart`, `*_repository.dart` (interface) / `*_repository_impl.dart` (impl), `*_data_source.dart`, `*_model.dart` (DTO) / entity names unsuffixed in `domain`, `*_provider.dart` / `*_notifier.dart`.
- Keep widgets small and composable; extract reusable widgets to `presentation/widgets/` (feature-local) or `core/` (shared).

## Commands

Run from `nova_project/` (the Flutter project root):

- Install deps: `flutter pub get`
- Run: `flutter run`
- Analyze/lint: `flutter analyze`
- Format: `dart format .`
- Test: `flutter test`
- Build Android: `flutter build apk` · iOS: `flutter build ios`

Run `flutter analyze` and `flutter test` before considering any change complete. Fix all analyzer warnings; do not suppress lints to pass.

## Do / Don't

- Do keep `domain` framework-free and dependency-light.
- Do inject dependencies via Riverpod so everything is testable.
- Do handle loading/empty/error states for every data-bound screen.
- Don't call APIs, Firebase, or Hive from widgets or presentation providers.
- Don't hardcode colors, strings-as-styling, or magic numbers — use theme tokens and constants.
- Don't put business logic in widgets.
- Don't add a new state-management, backend, or charting library alongside the locked choices.

## Adding a new feature (follow this so the rules never change)

1. Create `lib/features/<feature>/` with `data/`, `domain/`, `presentation/`.
2. Define entities and a repository **interface** + use cases in `domain` (pure Dart).
3. Implement the repository and its data sources in `data`; map DTOs to entities at the boundary.
4. Expose the repository/use cases as Riverpod providers.
5. Build screens and widgets in `presentation`, reading state via providers, in both themes, with all four states.
6. Add tests. Run `flutter analyze` and `flutter test`.

Growing the app this way requires no edit to this file.

## What must NOT go in this file

To keep this file durable, never add: lists of existing features/screens/files, build progress or status, "currently the app has…" descriptions, or anything that becomes stale when a feature is added. Track progress in a separate file or your issue tracker. Edit this file only to change a rule, convention, or locked decision.
