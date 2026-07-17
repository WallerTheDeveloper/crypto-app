# 10 · Settings

**Depends on:** [01](01-theme-tokens.md), [02](02-core-widgets.md), [03](03-mock-data-layer.md), [04](04-app-shell-nav.md)

Design reference: the `isSettings` block. Title "Settings" via the shared scaffold header.

This screen owns the **theme toggle** — the user-facing switch `CLAUDE.md` requires. The prototype's toolbar toggle is scaffolding; this is the real one.

## Profile card

`s1`, 1px `border`, radius 16, padding `16px 18px`, mb 22, row gap 14: 52px circular avatar (`accentGradient`, white "AR" 19px/600), then "Alex Rivera" 16px/500 over "alex@example.com" 13px `muted`, then a `muted` chevron-right (20px).

**Hardcoded, per the [no-auth MVP decision](README.md#mvp-definition).** Keep the strings in a constants file, not inline, so the auth swap is one edit. The chevron goes nowhere — no route, no dead `onTap` that silently does nothing. If a tap target with no destination bothers you, that's the right instinct: note it, don't invent a profile screen.

## Appearance

Section label "Appearance" 13px `muted`, margin `0 4px 10px`. Card `s1`, 1px `border`, radius 16, padding `16px 18px`, mb 22:

**Row 1** (mb 14), space-between: "Theme" 15px, and a segmented control on an `s2` track (1px `border`, pill, padding 3) — **Dark** / **Warm**, 13px/500, padding `7px 16px`.

**Row 2:** two swatch buttons, gap 10, each flex-1: `s2` fill, radius 12, padding 13, **1.5px** border — `accent` when selected, `border` when not. Column, gap 9, left-aligned:

- Three 16×16 chips (radius 5, gap 5) then a 12px `text` label.
- **A · Dark vibrant** — `#0D0B1A` (with a `#2A2247` border), `#B14BFF`, `#00F5A0`.
- **B · Warm playful** — `#FFF7F0` (with a `#E8D5C4` border), `#E8724C`, `#1D9E75`.

⚠️ The swatch chips are **literal theme previews** — they must show the *other* theme's colors while you're in one theme, so they can't be `AppColors` lookups. This is the sanctioned exception to the no-hex rule: expose both token sets as named constants from `core/theme/` and read them here. **Never** inline hex in this widget.

The toggle and the swatches drive the same state — selecting either updates both, and the whole app rethemes instantly and persists ([01](01-theme-tokens.md)).

## Preferences

Section label "Preferences". Grouped card, radius 16, `overflow: hidden`, 1px `border` divider between rows, mb 22:

- **Currency** (padding `16px 18px`, bottom divider): "Currency" 15px, `s2`-track segmented control **USD** / **EUR**. Writes prefs; every price app-wide reformats live — market, detail, portfolio, alerts.
- **Notifications** (padding `16px 18px`, no divider): "Notifications" 15px over "Price alerts & news" 12px `muted` (mt 2), and a toggle switch. Default **on**.

  Persists to prefs and does **nothing else** — no FCM in the MVP ([08](08-alerts.md)). Don't wire a permission request.

## Account group

Grouped card, radius 16, `overflow: hidden`, three rows at padding `16px 18px`, 15px, dividers between:

- "Account & security" — inert.
- "Help & support" — inert.
- "**Sign out**" — `loss` colored, tappable → toast "**Signed out**". That's the prototype's whole behaviour and, with no auth, it's the honest one. No confirm dialog, no state change.

Note the first two have no chevrons in the design. Don't add them.

## Copy

Exact: "Appearance", "Theme", "Preferences", "Currency", "Notifications", "Price alerts & news", "Account & security", "Help & support", "Sign out". Sentence case throughout. `&` renders as `&` (the design's `&amp;` is HTML escaping, not content).

## States

Not data-bound in the usual sense — prefs come from Hive and are effectively instant. No skeleton, no error state, no empty. Add a brief comment saying the four-state rule is deliberately N/A here, so a reviewer doesn't read it as an omission.

## Tests

- All sections and rows render with exact copy.
- Theme segmented control switches theme; app rethemes; choice persists across restart.
- Swatch buttons switch theme; selection border follows; toggle and swatches stay in sync.
- Swatches render the fixed brand hexes, not the active theme's tokens (i.e. the Dark swatch shows `#B14BFF` while in Warm).
- Currency switch persists and reformats prices on other screens (test at least Market and Portfolio).
- Notifications toggle persists across restart.
- "Sign out" toasts exactly "Signed out" and changes nothing else.
- Inert rows have no navigation.
- Both themes.

## Acceptance criteria

- [ ] Matches the `isSettings` block: 52px avatar, 1.5px swatch borders, grouped cards with internal dividers.
- [ ] Theme toggle is the real, persisted, app-wide switch.
- [ ] Swatch hexes come from named constants in `core/theme/`, not inlined.
- [ ] Currency change reformats every screen live.
- [ ] Copy exact and sentence case.
- [ ] No fake behaviour behind inert rows.
- [ ] Both themes verified.
- [ ] `flutter analyze` + `flutter test` clean.

## Files touched

`lib/features/settings/presentation/**` (screen, swatch, rows, providers), `lib/core/theme/*` (expose both token sets as constants), `lib/core/constants/*` (profile strings), `test/features/settings/**`
