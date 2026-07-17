# 05 · Market list

**Depends on:** [02](02-core-widgets.md), [03](03-mock-data-layer.md), [04](04-app-shell-nav.md) · **Blocks:** nothing

The default screen. Design reference: the `isMarket` block in the `.dc.html`.

## Header (custom — not the shared title)

Padding `8px 2px 14px`, space-between:

- **Left:** 30×30 rounded square (radius 9) in `accent` with a white `◈` glyph at 15px/600, then the app name **Nova** at 22px/600, letter-spacing -0.4, gap 9.
- **Right:** search icon button (38×38, radius 11, `s1`, 1px `border`) and a 38×38 circular avatar with `accentGradient` and white `AR` at 14px/600, gap 14.

App name is a constant, not a literal scattered around. The `AR` avatar is the hardcoded prototype user — fine for the MVP, no auth ([README](README.md#mvp-definition)).

## Portfolio snapshot strip

Above the list, tappable → Portfolio tab. `s1` fill, 1px `border`, radius 16, padding `16px 18px`, margin-bottom 18.

- Left: "Portfolio value" 12px `muted`, then total at 26px/500, letter-spacing -0.5.
- Right: "Today" 12px `muted`, then a **large** change badge.

⚠️ **Known design inconsistency:** the prototype labels this "Today" but feeds it `totalPlPctFmt` — all-time P/L, the same value the Portfolio hero labels "all time". Mock data has no intraday history, so a true "today" number doesn't exist yet. Build it as-is (all-time value under the "Today" label) and **flag it to the owner**; the fix is either relabelling to "All time" or adding intraday data. Don't quietly invent a daily number.

## Sort chips

Row of three, gap 8, margin-bottom 14. Active = `accent` fill + white 13px/500, padding `7px 14px`, pill. Inactive = `s1` fill, 1px `border`, `text` label.

- **Market cap** (default active) — sort by `price * circulatingSupply`, descending.
- **Gainers** — sort by `change24hPct`, descending.
- **Watchlist** — renders, **does nothing**. Deferred ([README](README.md#mvp-definition)). Don't fake it and don't hide it; the design shows three chips. Consider a disabled/inert look only if the owner agrees — default is inert but visually identical.

Sorting is a use case in `domain`, not a widget-level `.sort()`.

## Search

The header's search icon opens search over the list (the design doesn't draw the search field — it only implies it via the icon and the "No results" empty state). Recommendation: inline field replacing the header on tap, same 38px height, dismissible. **Confirm the interaction with the owner** — this is the one place the design is silent.

Filter on name **or** ticker, case-insensitive (the empty copy says "coin name or ticker"). Debounce input; no results → the empty state below.

## List

Rows 66px, 1px `border` bottom divider, gap 13, tappable → coin detail:

- 40px coin avatar (brand color, white glyph 15px/600).
- Flex column: name 15px/500, ticker 12px `muted`.
- 60×24 sparkline, `gain`/`loss` by direction.
- Right, min-width 88, right-aligned: price 15px/500 (`fmt`), change 12px/500 in `gain`/`loss` (`changePct`).

All eight coins. Currency follows the prefs from [03](03-mock-data-layer.md) — switching to EUR in Settings must update this list live.

## Four states

- **Loading:** 74px skeleton strip (radius 16, mb 18) → two pill skeletons (96×32, 78×32) → **six** row skeletons (40px circle, 60%×13 and 34%×11 bars, 80×26 block) at 66px with dividers.
- **Empty:** search-only. 64×64 well (radius 20, `s1` + `border`, `muted` search icon), "No results" 16px/500, "Try a different coin name or ticker to see live prices." 14px `muted`, max 230px. **No CTA.** Padding `70px 20px`.
- **Error:** 64×64 `lossWell` (radius 20) + `loss` warning icon, "Couldn't load market" 16px/500, "Check your connection and try again." max 240px, **Retry** primary. Padding `66px 20px`. Retry re-runs the fetch — don't just flip local state like the prototype does.
- **Populated:** as above.

States come from `AsyncValue`, never hand-rolled booleans. Note the loading skeleton covers the strip and chips too — the whole screen, not just the list.

## Tests

- Populated renders 8 rows with correct name/ticker/price/change.
- Market cap and Gainers reorder correctly; sorting use case unit-tested independently.
- Watchlist chip is inert (documents the deferral).
- Search filters by name and by ticker, case-insensitively; no match → empty state; clearing restores.
- Loading → 6 row skeletons + strip + chips.
- Error → message + working Retry.
- Row tap navigates to detail with the right coin id.
- Snapshot strip tap → Portfolio.
- Currency change updates prices without a reload.
- Both themes.

## Acceptance criteria

- [ ] Pixel match to the `isMarket` block: 66px rows, 88px price column, 18px margins.
- [ ] Sparklines and change text always `gain`/`loss`, never `accent`.
- [ ] All four states implemented and reachable via `MockConfig`.
- [ ] No data access in widgets — providers only.
- [ ] "Today" inconsistency raised, not silently resolved.
- [ ] Both themes verified.
- [ ] `flutter analyze` + `flutter test` clean.

## Files touched

`lib/features/market/presentation/**` (screen, widgets, providers/notifier), `lib/features/market/domain/usecases/*` (sort, search), `test/features/market/**`
