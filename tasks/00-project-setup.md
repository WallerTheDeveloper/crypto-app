# 00 · Project setup

**Depends on:** nothing · **Blocks:** everything

Turn the bare Flutter skeleton in `nova_project/` into the project `CLAUDE.md` describes. Right now it's `flutter create` output: default pubspec, counter-app `main.dart`, no dependencies.

## Dependencies

Add via `flutter pub add` from `nova_project/` — **do not hand-write version constraints**; let pub resolve current stable and check pub.dev if anything looks stale or discontinued.

| Package | For |
|---|---|
| `flutter_riverpod` | State management (locked decision) |
| `fl_chart` | Coin detail chart (locked decision) |
| `hive_ce`, `hive_ce_flutter` | Local storage — see note below |
| `intl` | Number/currency formatting |
| `mocktail` (dev) | Repository fakes in tests |

**Hive note:** `CLAUDE.md` locks in "Hive". The original `hive` package is no longer maintained; `hive_ce` ("community edition") is its maintained successor with the same API. Verify current status on pub.dev, then use `hive_ce` — it satisfies the locked decision. If it has been superseded again, raise it rather than silently picking a different store.

**No codegen in the MVP.** Skip `build_runner`, `riverpod_generator`, and Hive adapter generation. Persist models as JSON maps via hand-written `toJson`/`fromJson` (see [03](03-mock-data-layer.md)). Keeps the data layer explicit and the build fast.

## Font

The design uses **Inter** at weights 400, 500, 600 (see the conflict note in [README](README.md#conflicts-between-claudemd-and-the-design--decide-before-building)).

Bundle the TTFs under `nova_project/assets/fonts/` and declare them in `pubspec.yaml`. **Do not use `google_fonts`** — it fetches over the network at runtime, which breaks the offline-first behaviour `CLAUDE.md` requires and would leave text unstyled on a cold offline start.

## Folder scaffold

Create the tree from `CLAUDE.md`, with a `.gitkeep` in any dir that has no file yet:

```
lib/
  core/
    theme/          constants/       utils/
    error/          network/
  features/
    market/         portfolio/       alerts/       settings/
      (each with data/ domain/ presentation/)
  main.dart
test/
  core/  features/
```

## App entry

Rewrite `lib/main.dart`:

- Wrap the app in `ProviderScope`.
- `WidgetsFlutterBinding.ensureInitialized()`, then init Hive and open the boxes [03](03-mock-data-layer.md) declares, **before** `runApp`.
- Build `MaterialApp` with the theme wiring from [01](01-theme-tokens.md) — leave a `TODO` referencing 01 if that task hasn't landed yet.
- Delete the counter scaffold entirely.

Also delete the default `test/widget_test.dart` — it asserts on the counter app and will fail the moment `main.dart` changes.

## Analyzer

Keep `flutter_lints`. Add to `analysis_options.yaml` the rules that protect the locked architecture:

- `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`
- `avoid_print` (error — use a logger or nothing)
- `require_trailing_commas`

Do not add ignores to make existing code pass.

## Acceptance criteria

- [ ] `flutter pub get` succeeds; every locked dependency present, none beyond the list above without a written reason.
- [ ] `flutter analyze` clean on the scaffold.
- [ ] `flutter test` passes (zero tests is fine here — the counter test is gone, not skipped).
- [ ] `flutter run` boots to a blank themed scaffold, no counter, no red screen.
- [ ] Inter renders from the bundled asset with the network off.
- [ ] Folder tree matches `CLAUDE.md` exactly.

## Files touched

`pubspec.yaml`, `analysis_options.yaml`, `lib/main.dart`, `assets/fonts/*`, `lib/**/.gitkeep`, delete `test/widget_test.dart`
