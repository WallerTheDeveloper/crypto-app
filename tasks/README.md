# MVP task index

Build the Nova crypto dashboard MVP in `nova_project/`, driven entirely by **mock data**. No Firebase, no CoinGecko, no Binance websocket — those slot in behind the repository interfaces after the MVP lands.

Read `CLAUDE.md` (code conventions) and `crypto-dashboard-flutter-design/project/Crypto Dashboard.dc.html` (visual reference) before starting any task. Every task below assumes both.

## MVP definition

**In scope** — the five screens in the design, both themes, all four data states, and working add-holding / create-alert flows persisted to Hive.

**Out of scope for the MVP** (deliberate, decided 2026-07-16):

| Deferred | Why |
|---|---|
| Auth / login | The design has no login screen. Settings renders the fixed "Alex Rivera" profile from the prototype; "Sign out" only fires a toast. Firebase Auth arrives with the backend. |
| Watchlist chip | Needs a save-coin concept that appears nowhere in the design. The chip renders per the design but does not filter. |
| Real network + push | Mock data source stands in. Repository interfaces are shaped so the real sources drop in without touching presentation. |

## Task order

Numbers are order, not priority. Tasks at the same indent level are independent and can run in parallel.

```
00-project-setup          deps, folder scaffold, fonts, ProviderScope
├── 01-theme-tokens       both themes, tokens, theme controller
│   └── 02-core-widgets   buttons, badges, chips, skeletons, states
└── 03-mock-data-layer    entities, repo interfaces, mock sources, Hive

        02 + 03 ─→ 04-app-shell-nav      scaffold, bottom nav, sheet + toast hosts

                   04 ─┬─→ 05-market-list
                       ├─→ 06-coin-detail
                       ├─→ 07-portfolio
                       ├─→ 08-alerts
                       └─→ 10-settings

                   09-sheets-and-toast   add-holding + create-alert (05–08 wire triggers into it)

                   11-verification       coverage, analyze, both-theme sweep
```

`09` is listed after the screens because the screens own the trigger buttons, but the sheet itself only depends on `04`. If you parallelise, build `09` alongside `06`–`08` and let those tasks wire triggers to its provider.

## Files

- [00-project-setup.md](00-project-setup.md) — dependencies, folder scaffold, Inter font, app entry
- [01-theme-tokens.md](01-theme-tokens.md) — both theme token sets, `ThemeExtension`, persisted theme controller
- [02-core-widgets.md](02-core-widgets.md) — shared widget kit from the design's component sheet
- [03-mock-data-layer.md](03-mock-data-layer.md) — entities, repository interfaces, mock data sources, Hive, formatters
- [04-app-shell-nav.md](04-app-shell-nav.md) — app scaffold, bottom nav, sheet host, toast host
- [05-market-list.md](05-market-list.md) — market screen, snapshot strip, sort chips, search, four states
- [06-coin-detail.md](06-coin-detail.md) — coin detail, fl_chart, range toggle, stats grid
- [07-portfolio.md](07-portfolio.md) — hero, donut, legend, holdings list, four states
- [08-alerts.md](08-alerts.md) — alert list, toggles, empty state
- [09-sheets-and-toast.md](09-sheets-and-toast.md) — add-holding and create-alert sheets with real input
- [10-settings.md](10-settings.md) — profile, theme picker, currency, notifications
- [11-verification.md](11-verification.md) — analyze, test, coverage, both-theme review

## What NOT to build from the design file

The `.dc.html` is a prototype *harness* wrapped around the actual design. Recreate only the phone screen contents. Skip:

- The **phone frame** (404×832 bezel, notch, radial-gradient page background) — that's a mockup device.
- The **fake status bar** (9:41, signal/wifi/battery SVGs) — the real OS draws this.
- The **top toolbar** (theme A/B toggle, populated/loading/empty/error state selector) — prototype affordances. The real theme toggle lives in Settings; the real states come from `AsyncValue`.
- The **component sheet** at the bottom (two side-by-side theme panels) — that's a spec of the widgets in [02-core-widgets.md](02-core-widgets.md), not a screen.

Everything inside the `<div class="scrl">` screen area is real design.

## Conflicts between CLAUDE.md and the design — decide before building

These three are unresolved. Each task flags where it bites. **Raise with the project owner rather than guessing.**

1. **Font weights.** `CLAUDE.md`: "Two font weights only: 400 and 500." The design loads Inter 400/500/**600** and uses 600 for screen titles (22px), the sheet title (18px), coin avatar glyphs, and section labels. Recommendation: allow 600 and correct `CLAUDE.md`, since dropping to 500 flattens every screen title in the design.
2. **Corner radius scale.** `CLAUDE.md`: "cards 16, controls/buttons 12, pills fully rounded." The design also uses 9, 10, 11, 14, 20, 22 and 26 (sheet top). Recommendation: treat `CLAUDE.md`'s three as the defaults, and record the full scale as named radius tokens in [01-theme-tokens.md](01-theme-tokens.md).
3. **Chart line color.** `CLAUDE.md`: "`accent` is only for interactive elements (…, primary chart line)" and "never use `accent` to encode price movement." The coin-detail chart in the design strokes `gain`/`loss` by 24h direction. Recommendation: follow the design — that chart *is* price movement, so `gain`/`loss` is the semantically correct token, and `CLAUDE.md`'s "primary chart line" clause should be narrowed to non-price charts.

## Conventions for every task

- **Both themes, always.** Nothing is done until it's been looked at in Dark and Warm.
- **Four states on every data-bound screen**: loading (skeleton shimmer), empty (designed), error (message + retry), populated.
- **Tokens only.** No hex literals outside `core/theme/`. No magic numbers — use the spacing/radius constants.
- **Tests alongside**, not after. Each task lists its own test requirements. Target 80%+ coverage; `11` verifies.
- **`flutter analyze` and `flutter test` must be clean** before a task is considered complete. Don't suppress lints to pass.
- Run everything from `nova_project/`, not the repo root.
