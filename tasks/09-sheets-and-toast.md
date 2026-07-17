# 09 · Add-holding & create-alert sheets

**Depends on:** [02](02-core-widgets.md), [03](03-mock-data-layer.md), [04](04-app-shell-nav.md) · **Triggered by:** [06](06-coin-detail.md), [07](07-portfolio.md), [08](08-alerts.md)

The only two write paths in the app. Design reference: the `sheetOpen` block — one sheet with two variants, switched by `sheetIsAlert`.

**This task is where the MVP diverges from the prototype on purpose.** The prototype's sheet is a mannequin: the amount field is the literal string `0.00`, the target price is `fmt(price * 1.1)`, and confirm just fires a toast. Per the [MVP decision](README.md#mvp-definition), these take real input and persist to Hive. Match the design's *appearance* exactly; replace its stubbed behaviour.

## Shared chrome (from [04](04-app-shell-nav.md))

Host, scrim, panel, handle and `fadeUp` come from the sheet host. This task owns content only.

## Shared content

- **Title** 18px/600, mb 4 — "Set price alert" / "Add holding".
- **Subtitle** 13px `muted`, mb 20 — "Notify me when the price crosses a target." / "Enter how much {coin name} you own."
- **Coin selector row:** `s1`, 1px `border`, radius 14, padding `13px 15px`, mb 14, row gap 12 — 36px avatar, then name 15px/500 over `fmt(price)` 12px `muted`, then a chevron-down (18px, `muted`).

  The chevron promises a picker the prototype never implements. Two entry points need one: Portfolio's "+ Add" and Alerts' "+" open with **no coin preselected**. Build a real picker — tapping the row opens a coin list (reuse the Market row widget) that sets the selection. When opened from coin detail, that coin is preselected.

- **Value field:** `s1`, 1px `border`, radius 14, padding `13px 15px`, mb 20 — label 12px `muted` (mb 5), value **22px/500**, letter-spacing -0.3.

  The design renders a static display, not an input. Make it a real `TextField` styled to match exactly: 22px/500, no underline, no Material decoration, cursor in `accent`, numeric keyboard (`decimal`). It must look identical to the mockup while being editable.

- **CTA:** full-width primary, radius 12, padding 15, 15px/500.

## Variant: add holding

- Title "Add holding" · subtitle "Enter how much {name} you own." · field label "Amount ({TICKER})" · CTA "Add to portfolio".
- Default `0.00`; select-all on focus so typing replaces it.
- **No direction selector** (that's alert-only).

**Missing from the design:** average buy price. `Holding` needs `averageBuyPrice` — the whole P/L feature depends on it ([07](07-portfolio.md)) — but the sheet only collects amount. Unresolvable silently. Options:

1. Add a second field ("Average buy price") — extends the design, keeps P/L honest. **Recommended.**
2. Use the current price as the cost basis — new holdings always show `+0.00 (0.0%)` P/L, which looks broken.
3. Prompt separately later — worst of both.

**Ask the owner before building this sheet.** Option 1 changes a designed screen; option 2 makes the headline feature lie. Not a judgement call to make quietly.

## Variant: set price alert

- Title "Set price alert" · subtitle "Notify me when the price crosses a target." · field label "Target price" · CTA "Create alert".
- **Direction selector** above the field (mb 14), row gap 10, two flex-1 buttons radius 12 padding 13, 14px/500: **Above** (primary when selected) / **Below** (secondary when not). Default **Above**.
  The prototype hardcodes Above as active and neither button does anything — make it a real two-way selection.
- Default target = `fmt(round(price * 1.1))`, i.e. 10% above current, per the design. Keep 1.1 a named constant.
- Direction and target both feed the `Alert` entity ([03](03-mock-data-layer.md)).

## Validation

The prototype has none. `CLAUDE.md` requires validation at boundaries — and this is *the* boundary:

- Reject empty, non-numeric, negative, and zero.
- Reject absurd precision (>8dp) and values that overflow a double.
- Require a selected coin.
- Disable the CTA while invalid rather than failing on submit — cheaper feedback, no error state needed.
- Validate in `domain` (a use case), not the widget, so it's unit-testable without a `WidgetTester`.

Parse with the **locale in mind**: `double.parse` wants `.` — if the field ever accepts `,` as a decimal separator, normalise first.

## Confirm

1. Validate. Invalid → CTA stays disabled; never submit.
2. Write through the repository to Hive (copy-on-write).
3. Close the sheet.
4. Toast: "**Added to portfolio**" / "**Alert created**" — exact strings from the prototype.
5. The originating screen updates from the stream. No manual refresh, no navigation hack.

On failure: keep the sheet open, keep the input, show the typed failure's message. Don't toast success on a failed write — the prototype toasts unconditionally because it never writes.

## Keyboard

A real text field in a bottom sheet means the keyboard covers the CTA. Handle `viewInsets` in the host ([04](04-app-shell-nav.md)) so the panel rises. Verify on a small device; this is the most common way a sheet like this ships broken.

## Tests

- Both variants render exactly (title, subtitle, label, CTA).
- Add holding: valid amount → holding persisted, sheet closed, toast, portfolio updated.
- Create alert: direction + target → alert persisted, correct condition copy on [08](08-alerts.md).
- Direction selector toggles and drives the entity.
- Default target = `round(price * 1.1)`, formatted.
- Validation rejects: empty, `abc`, `-1`, `0`, 20-decimal input, no coin. CTA disabled for each; use case unit-tested standalone.
- Coin picker sets the selection; preselection works from detail.
- Repository failure keeps the sheet open, preserves input, shows the message, and does **not** toast success.
- Scrim tap dismisses without writing.
- Keyboard doesn't cover the CTA.
- Both themes.

## Acceptance criteria

- [ ] Visually identical to the `sheetOpen` block, including the 22px/500 field.
- [ ] Field is a real, styled, numeric `TextField`.
- [ ] Coin picker works from all entry points.
- [ ] Average-buy-price question resolved with the owner **before** building.
- [ ] Validation in `domain`, CTA gated on it.
- [ ] Writes hit Hive and survive restart.
- [ ] Toast copy exact; only on success.
- [ ] Keyboard handled.
- [ ] Both themes verified.
- [ ] `flutter analyze` + `flutter test` clean.

## Files touched

`lib/features/portfolio/presentation/widgets/add_holding_sheet.dart`, `lib/features/alerts/presentation/widgets/create_alert_sheet.dart`, shared sheet parts in `lib/core/widgets/` or a shared feature dir, `lib/features/*/domain/usecases/*` (validation, add), `test/features/**`
