# 02 · Core shared widgets

**Depends on:** [01](01-theme-tokens.md) · **Blocks:** [04](04-app-shell-nav.md) and every screen

The design's **component sheet** (bottom of the `.dc.html`, rendered twice — once per theme) is the spec for this task. It exists precisely to say "these are the reusable pieces." Build them once in `lib/core/widgets/`; screens compose, never re-roll.

Every widget here takes its colors from `AppColors`. Every one must be checked in both themes.

## The kit

### Buttons
- **Primary** — `accent` fill, white text, radius 12, padding 12–15, 14–15px/500. Full-width and flex variants.
- **Secondary** — transparent fill, `text` label, 1px `borderStrong` border, radius 12, same metrics.
- **Icon button** — 38×38, radius 11, `s1` fill, 1px `border`, `text` icon. (Back button, alerts "+" uses `accent` fill with white icon instead.)
- **Text/accent button** — bare, `accent` label, used for "+ Add" in the portfolio header.

### Price-change badge
Three variants, all pill radius, 500 weight:
- up → `gain` text on `gainSoft`; label `+2.4%`
- down → `loss` text on `lossSoft`; label `-1.2%`
- neutral → `muted` text on `mutedSoft`; label `0.0%`

Two sizes: **small** (12px, padding 4×9 — market rows, snapshot strip) and **large** (14px, padding 6×12 — coin detail, portfolio hero).

Take a signed number and derive sign/color/format internally — don't make callers pass a color. This is the widget that enforces the gain/loss rule, so make it impossible to misuse.

### Coin avatar
Circle, coin's brand color fill, white glyph, weight 600. Sizes 40 / 38 / 36 / 26. Brand colors ship with the coin fixture ([03](03-mock-data-layer.md)) — they are **not** theme tokens (Bitcoin is `#F7931A` in both themes), so this is the one sanctioned place a non-token color is painted. Take it as a parameter; never hardcode.

### Sparkline
60×24 (`viewBox` 64×24), stroke 1.8, round caps/joins, no fill. Stroke = `gain`/`loss` by direction. Smoothed, not polyline — see the curve note in [06](06-coin-detail.md); reuse the same path helper.

Cheap enough to be a `CustomPainter`; don't reach for fl_chart at this size.

### Segmented control
Pill track (`s1`/`s2` fill, 1px `border`, padding 3) with segments: active = `accent` fill + white; inactive = transparent + `muted`. 13px/500, padding 7×15–16. ~150ms transition.

Generic over its item type — Settings uses it for theme and currency, coin detail for the range toggle (radius 12 track, radius 9 segments, `flex:1`, padding 9).

### Toggle switch
Track 46×27, pill, `accent` when on / `borderStrong` when off. Knob 21×21 white circle, top 3, left 3→22, 200ms. Used by alerts and notifications.

### Cards
- **Surface card** — `s1` fill, 1px `border`, radius 16. The workhorse (stat cards, alert rows, settings groups).
- **Grouped list card** — radius 16, `overflow: hidden`, 1px `border` dividers between rows, no divider after the last. Settings uses this.

### Skeleton shimmer
Horizontal gradient `s1 25% → s2 37% → s1 63%`, background-size 320px, translating -320→320 over **1.3s linear infinite**. Expose as a box with a size + radius so screens can shape their own skeletons.

Must animate — a static grey block is not this component.

### Empty state
Centered: icon well (74×74, radius 22, `accentWell` fill, `accent` icon), title 18px/500, body 14px `muted` capped ~250px wide, then a primary CTA. Market's variant is smaller (64×64 well, radius 20, `s1` fill + `border`, `muted` icon, 16px title, no CTA) — parameterise rather than forking.

### Error state
Centered: icon well 64×64, radius 20, `lossWell` fill, `loss` warning icon, title 16px/500, body 14px `muted`, **Retry** primary button. Takes a message + `onRetry`.

### Toast
`s2` fill, 1px `borderStrong`, radius 14, padding 12×18, shadow `0 12px 30px -10px rgba(0,0,0,.5)`. Leading 22px `gain` circle with a white check, then 14px/500 label. Enters with `toastIn` (fade + 12px rise, 300ms), sits 100px off the bottom, auto-dismisses at **2200ms**.

Widget only here; the host/controller lives in [04](04-app-shell-nav.md).

### Icons
The four nav icons (market/portfolio/alerts/settings) plus search, back, plus, chevron, warning, bell are inline SVG paths in the design at stroke-width ~1.6–1.9, round caps/joins.

Material's icon set does **not** match these shapes. Port the paths — either as a small `CustomPainter`/`Path` set or by bundling them as SVG assets. Don't substitute lookalike Material icons; the design's line weight is a deliberate, visible characteristic.

## Tests

Widget tests for each, both themes:

- Badge picks gain/loss/neutral and formats sign correctly across positive, negative and exactly zero.
- Segmented control reports the tapped item and only paints one segment active.
- Toggle animates between the two positions and reports changes.
- Skeleton actually animates (pump and assert the shimmer offset moves).
- Empty/error states render their message and fire their callbacks.
- Toast auto-dismisses at 2200ms (`pump` past it and assert it's gone).
- Golden tests are welcome here if you want them anywhere — this is the highest-leverage place.

## Acceptance criteria

- [ ] Every component sheet item exists as a reusable widget.
- [ ] Both themes verified for all of them.
- [ ] No hex outside `core/theme/` — coin brand colors arrive as parameters.
- [ ] Animation timings match: shimmer 1.3s, toast 2200ms + 300ms in, toggle 200ms, segments ~150ms.
- [ ] Widgets are dumb: no repository, no provider reads, no business logic. Data and callbacks in, events out.
- [ ] `flutter analyze` + `flutter test` clean.

## Files touched

`lib/core/widgets/*.dart` (one primary widget per file, `snake_case` matching the class), `lib/core/widgets/icons/*`, `test/core/widgets/*`
