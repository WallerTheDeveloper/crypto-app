# 07 · Portfolio

**Depends on:** [02](02-core-widgets.md), [03](03-mock-data-layer.md), [04](04-app-shell-nav.md) · **Related:** [09](09-sheets-and-toast.md)

Design reference: the `isPortfolio` block. Title "Portfolio" via the shared scaffold header.

## Hero

Centered, padding `12px 0 8px`, enters with `fadeUp` (opacity 0→1 + 8px rise, **500ms** ease):

- "Total value" 13px `muted`, mb 8.
- Total at **44px/500**, letter-spacing **-1px**, line-height 1, mb 14. This is the biggest number in the app — the letter-spacing is load-bearing, don't drop it.
- Inline row, gap 8: large P/L badge (absolute), large P/L badge (percent), then "all time" 13px `muted`.

Both badges take their color from the same sign — they can never disagree.

## Math (port exactly from the design)

Per holding: `value = amount * price` · `cost = amount * avg` · `pl = value - cost` · `plPct = pl / cost * 100`

Totals: `total = Σ value` · `totalCost = Σ cost` · `totalPl = total - totalCost` · `totalPlPct = totalPl / totalCost * 100`

Formatting:
- `plFmt` = sign + `fmt(|pl|)` + ` (` + sign + `|plPct|.toFixed(1)` + `%)` → `+$5,048.14 (+23.1%)`. Note the sign appears **twice** and the magnitudes are absolute — the sign is separate from the number.
- `totalPlFmt` = sign + `fmt(|totalPl|)`; `totalPlPctFmt` = sign + `totalPlPct.toFixed(1)` + `%`.
- `allocFmt` = `(value / total * 100).toFixed(0)` + `%` — **0 decimals**.

Zero is positive (`pl >= 0` → up), per the design. Guard `totalCost == 0` and `total == 0` (empty or free holdings) — the prototype divides by them unguarded and would emit `NaN`. Don't reproduce that bug.

This is a use case in `domain`, unit-tested independently. No math in widgets.

## Donut + legend

Card: `s1`, 1px `border`, radius 16, padding 18, margin `22px 0 20px`, row, gap 20.

**Donut** — 128×128, `CustomPainter` (not fl_chart; it's a stroked arc set):
- Track: full circle r=52, stroke **18**, `border` color.
- Segments: r=52, stroke 18, **butt** caps, coin brand color, starting at -90° (12 o'clock), clockwise.
- Per segment: `frac = value / total`, `dash = frac * circumference` where `circumference = 2π * 52`. The design's dash array is `(dash - 2) (circ - dash + 2)` and offset `-acc` (accumulating) — the **-2 is a deliberate 2px gap** between segments. Reproduce it: sweep `dash - 2`, advance by the full `dash`.
- Center: holding count 20px/500 (letter-spacing -0.3) over "assets" 11px `muted`.

**Legend** — flex column, gap 11, one row per holding: 10×10 swatch (radius **3**, brand color), ticker 13px, then `allocFmt` 13px `muted`, right-aligned.

Brand colors here are data, not tokens — same rule as the avatar.

## Holdings

Section header, space-between, mb 6: "Holdings" 16px/500, and an accent text button "**+ Add**" (14px/500, plus icon 17px stroke 2, gap 5) → add-holding sheet.

Rows **70px** (taller than Market's 66), 1px `border` divider, gap 13:
- 40px coin avatar.
- Name 15px/500, then `amountFmt` = `amount + ' ' + ticker` 12px `muted` (e.g. `0.42 BTC` — raw amount, not currency-formatted).
- Right: `valueFmt` 15px/500, `plFmt` 12px/500 in `gain`/`loss`.

Order follows the holdings list. Currency follows prefs — EUR updates hero, rows, and legend live.

## Four states

- **Loading:** 120px skeleton (radius 16, margin `12px 0 22px`) for the hero → 128px skeleton (radius 16, mb 22) for the donut card → **four** 70px row skeletons (40px circle, 55%×13 + 30%×11 bars, 70×26 block).
- **Empty:** the real one — no holdings. 74×74 `accentWell` (radius 22) with the `accent` portfolio/pie icon (34px), "Start your portfolio" **18px/500**, "Add your first holding to track value and profit over time." 14px `muted` max 250px, then primary CTA "**Add your first holding**" → add-holding sheet. Padding `64px 22px`.
- **Error:** 64×64 `lossWell`, "Couldn't sync portfolio" 16px/500, "Your holdings are safe. Try syncing again." max 240px, Retry.
- **Populated:** as above.

The empty state is reachable for real: delete every holding. Make sure it appears without a restart.

## Tests

- Hero: total, P/L, P/L% for the seed holdings; verify against hand-computed values.
- P/L math: profit, loss, exactly zero, `totalCost == 0` (no NaN, no crash).
- Allocations sum to ~100% and round to 0dp.
- Donut: segment sweeps proportional to value; gap applied; starts at -90°; single holding → near-full ring.
- Rows show correct amount/value/P/L; colors follow sign.
- Loading → 4 skeleton rows.
- Empty appears when holdings are removed, CTA opens the sheet.
- Error + Retry.
- Currency switch updates hero, rows, legend.
- Adding a holding via [09](09-sheets-and-toast.md) updates hero, donut and list without a reload.
- Both themes.

## Acceptance criteria

- [ ] Matches the `isPortfolio` block: 44px hero, 128px donut, 70px rows.
- [ ] Math matches the design, with the divide-by-zero holes closed.
- [ ] Donut is a `CustomPainter` with correct gaps and start angle.
- [ ] All four states; empty reachable by deleting holdings.
- [ ] Hero `fadeUp` at 500ms.
- [ ] Both themes verified.
- [ ] `flutter analyze` + `flutter test` clean.

## Files touched

`lib/features/portfolio/presentation/**` (screen, donut painter, legend, holding row, providers), `lib/features/portfolio/domain/usecases/*` (P/L, allocation), `test/features/portfolio/**`
