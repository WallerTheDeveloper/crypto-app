# 08 · Alerts

**Depends on:** [02](02-core-widgets.md), [03](03-mock-data-layer.md), [04](04-app-shell-nav.md) · **Related:** [09](09-sheets-and-toast.md)

Design reference: the `isAlerts` block. The simplest screen — most of its weight is in the sheet ([09](09-sheets-and-toast.md)).

## Header

Custom (not the shared title): padding `8px 2px 18px`, space-between — "Alerts" 22px/600 letter-spacing -0.4, and a **38×38 `accent`-filled** icon button (radius 11, white plus, stroke 2) → create-alert sheet.

Note this differs from the standard icon button ([02](02-core-widgets.md)): accent fill, no border. It's a primary action.

## Alert list

Column, gap 12 (cards, not dividers — unlike Market/Portfolio rows). Each card: `s1`, 1px `border`, radius 16, padding `15px 16px`, row, gap 13:

- 40px coin avatar (brand color, white glyph 15px/600).
- Flex column: coin name 15px/500, then condition 13px `muted` — `"When price goes {above|below} {fmt(target)}"`. Exact copy, sentence case, currency-formatted target.
- Toggle switch ([02](02-core-widgets.md)), 46×27, `accent` on / `borderStrong` off.

Seeds ([03](03-mock-data-layer.md)): `btc above $70,000.00` **on** · `eth below $2,800.00` **off** · `sol above $160.00` **on**. Note the seeds deliberately include an off alert — the design shows both toggle states side by side.

Toggling writes through the repository to Hive and survives restart. Optimistic UI is fine; on failure revert **and** surface it — never let the switch lie about persisted state.

## Delete

The design has no delete affordance, but alerts you can only ever add is a dead end, and the empty state is otherwise unreachable in normal use.

Recommendation: **swipe-to-dismiss** on the card (`Dismissible`), no new visual language, no design deviation on screen. **Confirm with the owner before building** — it's the one interaction with no reference. If it's rejected, the empty state is only reachable via `MockConfig` and the deferral should be recorded here.

Do not add a confirm dialog — [04](04-app-shell-nav.md) has no dialog host, and the toast is the established feedback pattern.

## States

Only **two** in the design (`alertsShow` = not empty, `alertsEmpty` = empty):

- **Populated:** the list.
- **Empty:** 74×74 `accentWell` (radius 22) + `accent` bell (32px), "No alerts yet" 18px/500, "Get notified the moment a coin crosses a price you care about." 14px `muted` max 250px, primary CTA "**Create an alert**" → sheet. Padding `64px 22px`.
- **Loading / Error:** the design draws neither, but `CLAUDE.md` requires all four on data-bound screens. Add them using the standard components — skeleton three 70-ish px cards; error copy "Couldn't load alerts" + Retry. Flag the addition as intentional so it doesn't read as design drift.

## Firebase note

Real alerts fire via Cloud Messaging + a Cloud Function checking thresholds server-side. **None of that is in the MVP.** Alerts are stored and toggled locally; nothing fires. Don't build a local notification stand-in — it'd be throwaway and would mislead anyone testing.

The `Alert` entity and repository must be shaped so the Cloud Function swap needs no presentation change.

## Tests

- Three seeded alerts render with correct coin, condition copy, and toggle state.
- Condition string exact for both directions and currencies (`"When price goes above $70,000.00"` / EUR equivalent).
- Toggle flips, persists, survives restart.
- Toggle failure reverts and reports.
- Empty state when all alerts are gone; CTA opens the sheet.
- Header "+" opens the sheet with no coin preselected.
- Creating an alert via [09](09-sheets-and-toast.md) prepends/appends it without a reload.
- Swipe-to-delete removes and persists (if approved).
- Loading and error states.
- Both themes.

## Acceptance criteria

- [ ] Matches the `isAlerts` block: 12px-gap cards, radius 16, accent "+" button.
- [ ] Condition copy is exact and currency-aware.
- [ ] Toggles persist across restart.
- [ ] Empty state reachable and correct.
- [ ] Loading/error added per `CLAUDE.md` and flagged as additions.
- [ ] No local-notification stand-in.
- [ ] Both themes verified.
- [ ] `flutter analyze` + `flutter test` clean.

## Files touched

`lib/features/alerts/presentation/**` (screen, alert card, providers), `test/features/alerts/**`
