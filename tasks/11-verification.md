# 11 · Verification

**Depends on:** everything

The gate before the MVP is called done. Nothing new gets built here — this task finds what the others missed.

## Automated

From `nova_project/`:

```bash
flutter analyze                          # zero issues. Not "zero errors" — zero.
dart format --set-exit-if-changed .      # formatted
flutter test                             # all green
flutter test --coverage                  # ≥ 80% overall
```

Coverage floors: `domain` and `core/utils` ≥ **90%** (pure logic, no excuse); overall ≥ **80%** per `CLAUDE.md`. Generate an lcov report and read it — a passing number with untested P/L math is a failing MVP. Check *what* is covered, not just the percentage.

If a lint was suppressed to get green, that's a finding. `CLAUDE.md`: "do not suppress lints to pass."

## Architecture

- No file under `features/*/domain/` imports Flutter, Firebase, Hive, http, or `dart:ui` (the test from [03](03-mock-data-layer.md) — confirm it's real and passing).
- No widget or presentation provider touches a data source, Hive box, or API directly.
- Presentation depends on repository **interfaces** only — grep for `Impl` outside `data/` and providers.
- DTOs stay in `data/`; no `_model.dart` type reaches a widget.
- Grep for hex literals outside `core/theme/`. Expected exceptions, and only these: coin brand colors (data, from fixtures) and the Settings swatches ([10](10-settings.md)).
- File/class naming per `CLAUDE.md`: `snake_case.dart`, one primary public class, suffixes correct.
- Files under 800 lines, functions under 50, nesting under 4.

## Both themes, every screen

Walk all five screens **in Dark and in Warm** — 10 passes. For each: contrast is readable, borders visible, nothing hardcoded to one theme's assumptions (light text on a light card is the classic failure).

Then switch theme *while on each screen* and confirm no flash, no rebuild artifact, no lost scroll.

## Four states, every data screen

Drive each via `MockConfig` ([03](03-mock-data-layer.md)):

| Screen | Loading | Empty | Error | Populated |
|---|---|---|---|---|
| Market | skeletons | search no-match | retry works | 8 coins |
| Coin detail | skeletons | N/A (documented) | retry works | chart + stats |
| Portfolio | skeletons | delete all holdings | retry works | hero + donut |
| Alerts | skeletons | delete all alerts | retry works | 3 alerts |

Every Retry must actually re-run the fetch, not flip local state.

## Design fidelity

Read the `.dc.html` screen blocks side by side with the running app. Check the numbers that are easy to drift: 66px market rows, 70px portfolio rows, 44px hero, 128px donut, 170px chart, 84px nav, 18px screen padding, 108px bottom padding.

Confirm the animations: shimmer 1.3s, toast 2200ms (+300ms in), hero fadeUp 500ms, sheet fadeUp 300ms, toggle 200ms, segments 150ms, chart draw-in 1.1s (or its documented deviation).

Confirm the semantics: `gain`/`loss` for every price movement and P/L; `accent` for every interactive element; no crossover in either direction.

## Persistence

Cold-restart and verify each survives: added holdings, created alerts, alert toggle states, theme choice, currency, notifications toggle. Then verify seeds do **not** overwrite user data on a subsequent launch.

## Offline

Airplane mode. The app is fully mock, so **everything must work** — no spinner-forever, no error state. If anything breaks offline, something is reaching for a network it shouldn't have.

## Open questions — close them

None of these should still be open at the end. Chase them down:

1. **Font weight 600** — allowed, or drop to 500? (conflict 1)
2. **Radius scale** — record the design's real scale, or force `CLAUDE.md`'s three? (conflict 2)
3. **Chart line color** — gain/loss per the design, or accent per `CLAUDE.md`? (conflict 3)
4. **Average buy price** — added to the add-holding sheet, or cost basis = current price? ([09](09-sheets-and-toast.md))
5. **"Today" label** on the market snapshot strip, showing all-time P/L ([05](05-market-list.md))
6. **Alert delete** — swipe-to-dismiss approved? ([08](08-alerts.md))
7. **Search interaction** — inline field confirmed? ([05](05-market-list.md))

Whatever gets decided, **write it into `CLAUDE.md`** if it changes a rule or a locked decision. `CLAUDE.md` says it's edited only to change a rule or convention — a resolved conflict is exactly that. Don't leave the rules contradicting the shipped app.

## Acceptance criteria

- [ ] `flutter analyze` clean, no new suppressions.
- [ ] `dart format` clean.
- [ ] All tests pass; ≥80% overall, ≥90% in `domain`/`utils`, verified by reading the report.
- [ ] Architecture checks pass, including the `domain` purity test.
- [ ] 5 screens × 2 themes reviewed.
- [ ] 4 states verified on every data-bound screen.
- [ ] Animation timings and key dimensions match.
- [ ] All persistence survives a cold restart.
- [ ] Fully functional offline.
- [ ] All 7 open questions closed, and `CLAUDE.md` updated for any that changed a rule.

## Files touched

Ideally none — this task reports. Fixes it finds belong in the task that owns the code, so the ownership stays legible in the history.
