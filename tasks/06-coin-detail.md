# 06 · Coin detail

**Depends on:** [02](02-core-widgets.md), [03](03-mock-data-layer.md), [04](04-app-shell-nav.md) · **Related:** [09](09-sheets-and-toast.md)

Pushed from a Market row. Design reference: the `isDetail` block. Nav bar stays visible; Market stays lit.

## Header

Padding `8px 0 16px`, space-between:

- Back icon button (38×38, radius 11, `s1`, 1px `border`, chevron-left stroke 1.9) → Market.
- Center: 26px coin avatar (brand color, glyph 12px/600) + name 16px/500, gap 9.
- Right: an empty 38px spacer so the center stays optically centered. Keep it.

## Price block

- "`{TICKER}` · price" 13px `muted`, mb 6.
- Row, baseline-aligned, gap 12: price 33px/500, letter-spacing -0.5, line-height 1 — then a **large** change badge.

## Chart

`fl_chart` `LineChart`, full width, **170px** tall, margin `22px 0 8px`.

- Line: stroke **2.4**, round caps/joins, colored `gain`/`loss` by the coin's 24h change. See conflict 3 in the [README](README.md#conflicts-between-claudemd-and-the-design--decide-before-building) — the design says gain/loss, `CLAUDE.md`'s wording suggests accent. Follow the design; get it confirmed.
- Area fill: vertical gradient from `gainFill`/`lossFill` (34% alpha) at top → transparent at bottom.
- No axes, no grid, no labels, no dots. The design draws none.
- Data: the deterministic series from [03](03-mock-data-layer.md), by `(coinId, range)`.

**Curve fidelity:** the design smooths with a Catmull-Rom-style cubic (control points at ±1/6 of the neighbour delta). `fl_chart`'s `isCurved: true` + `curveSmoothness` is the same family — `curveSmoothness: 0.35` is the usual match for 1/6 tangents. Tune against the prototype's rendering and don't use `preventCurveOverShooting` unless the line visibly overshoots.

**Draw-in animation:** the design animates the stroke via `stroke-dashoffset` 1400→0 over **1.1s ease** (`drawIn`). `fl_chart` has no dash-offset animation; approximate by animating the visible data range in over 1.1s. If it can't be made to look right, a fade is acceptable — but say so rather than shipping a silent mismatch.

## Range toggle

Segmented control ([02](02-core-widgets.md)), track `s1` + 1px `border`, radius **12**, padding 4, gap 3, mb 22. Segments flex-1, radius **9**, padding 9, 13px/500; active `accent`+white, inactive transparent+`muted`.

Ranges **24h · 7d · 30d · 1y**, default **7d**. Changing range refetches the series — different point counts (30/40/44/48) per [03](03-mock-data-layer.md).

## Stats grid

2×2, gap 12, mb 24. Each: `s1`, 1px `border`, radius 16, padding `15px 16px`; label 12px `muted` (mb 7), value 16px/500.

| Label | Value |
|---|---|
| Market cap | `big(price * circulatingSupply)` |
| 24h volume | `big(volume24h)` |
| Circulating supply | `compact(supply) + ' ' + ticker` |
| All-time high | `fmt(ath)` |

## Actions

Row, gap 12: **Add to portfolio** (primary, flex 1, radius 12, padding 15, 15px/500) → opens the add-holding sheet with this coin preselected. **Set alert** (secondary) → opens the create-alert sheet, same. Both via the sheet provider from [04](04-app-shell-nav.md); content in [09](09-sheets-and-toast.md).

## States

The design draws only the populated detail — loading/error still apply per `CLAUDE.md` (it's data-bound):

- **Loading:** skeleton the price block, chart box and stat cards, matching their real dimensions. Reuse [02](02-core-widgets.md)'s shimmer.
- **Error:** the standard error state, copy "Couldn't load coin" + Retry.
- **Empty:** not applicable — a coin always has data. Say so in a comment so the next reader doesn't think it was forgotten.

## Tests

- Renders name, ticker, price, badge for the routed coin.
- All four stats compute and format correctly (unit-test the math separately from the widget).
- Range change refetches and swaps the series; point count matches the range.
- Chart line/fill flip gain↔loss with change direction (test a positive and a negative coin — `btc` and `eth`).
- Series is deterministic: same `(id, range)` twice → identical points.
- Back returns to Market; Market stays lit throughout.
- Both action buttons request the right sheet with the right coin.
- Loading and error states.
- Both themes.

## Acceptance criteria

- [ ] Matches the `isDetail` block: 170px chart, 33px price, 2×2 grid.
- [ ] Chart has no axes/grid/dots.
- [ ] Line and fill are gain/loss, never accent (pending conflict 3).
- [ ] Range toggle drives real data.
- [ ] Deterministic series across rebuilds.
- [ ] Draw-in approximated, or its deviation reported.
- [ ] Both themes verified.
- [ ] `flutter analyze` + `flutter test` clean.

## Files touched

`lib/features/market/presentation/**` (detail screen, chart, range toggle, stats grid, providers), `test/features/market/**`
