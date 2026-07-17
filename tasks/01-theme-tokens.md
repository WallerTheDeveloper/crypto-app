# 01 · Theme tokens

**Depends on:** [00](00-project-setup.md) · **Blocks:** [02](02-core-widgets.md), [04](04-app-shell-nav.md), all screens

Both themes, as the single source of truth for color. Everything downstream reads tokens; nothing downstream writes hex.

The two themes are **structurally identical** — same layout, same spacing, only token values differ. Never fork a layout per theme.

## Token values — copy exactly

Lifted verbatim from `THEMES` in the design file. These are the spec; don't "improve" them.

| Token | A · Dark vibrant | B · Warm playful |
|---|---|---|
| `bg` | `#0D0B1A` | `#FFF7F0` |
| `s1` (surface 1) | `#16122B` | `#FFFFFF` |
| `s2` (surface 2) | `#1E1838` | `#FFFCF8` |
| `border` | `#2A2247` | `#F2E2D4` |
| `borderStrong` | `#3A3157` | `#E8D5C4` |
| `text` | `#F0EDFF` | `#3A2A1E` |
| `muted` | `#9B8CE0` | `#B08968` |
| `accent` | `#B14BFF` | `#E8724C` |
| `gain` | `#00F5A0` | `#1D9E75` |
| `loss` | `#FF5C7A` | `#E24B4A` |

Theme A is the default (`initialTheme: 'A'` in the prototype).

## Semantic rules (strict — from CLAUDE.md)

- `gain` → price up / profit. `loss` → price down / loss.
- `accent` → interactive only: buttons, active tabs/chips, selected states, toggle-on tracks.
- **Never** `accent` for price movement. **Never** `gain`/`loss` for generic UI.
- Exception under review: the coin-detail chart line strokes `gain`/`loss` per the design. See conflict 3 in the [README](README.md#conflicts-between-claudemd-and-the-design--decide-before-building).

## Implementation

- A `ThemeExtension` (e.g. `AppColors`) carrying the ten tokens, with real `copyWith`/`lerp`. Widgets reach tokens through it, not through `Theme.of(context).colorScheme`.
- Two `ThemeData` instances built from the two token sets. Also populate `ColorScheme`/`TextTheme` sensibly so stock Material widgets don't look alien, but features must read `AppColors`.
- Keep `AppColors` immutable (`const` constructor, final fields) — global rule: never mutate, always copy.

### Derived colors

The design derives several colors with CSS `color-mix`. Flutter has no equivalent, so provide helpers on the extension rather than scattering `withOpacity` calls:

| Design | Meaning | Helper |
|---|---|---|
| `color-mix(in srgb, var(--gain) 15%, transparent)` | badge background | `gainSoft` (15% alpha over transparent) |
| `…var(--loss) 15%…` | badge background | `lossSoft` |
| `…var(--loss) 14%…` | error-state icon well | `lossWell` |
| `…var(--accent) 12%…` | empty-state icon well | `accentWell` |
| `…var(--muted) 15%…` | neutral 0.0% badge | `mutedSoft` |
| `…var(--gain) 34%…` | chart area gradient top | `gainFill` |
| `…var(--loss) 34%…` | chart area gradient top | `lossFill` |
| `…var(--s1) 92%…` | bottom nav (over blur) | `navSurface` |
| `linear-gradient(135deg, var(--accent), color-mix(accent 40%, #000))` | avatar gradient | `accentGradient` |

`color-mix(X n%, transparent)` is alpha `n%`. `color-mix(X 40%, #000)` is X darkened toward black at 40/60 — compute it, don't eyeball it.

## Other tokens

**Radius** (`core/theme/`, named constants — the design's real scale, wider than `CLAUDE.md`'s three; see conflict 2):

`pill` = fully rounded · `card` = 16 · `control` = 12 · `sheet` = 26 (top only) · `inner` = 14 (sheet cards, toast) · `iconButton` = 11 · `chartBox` = 9/10 · `well` = 20–22 (empty/error icon wells)

**Typography** — Inter. Sizes seen in the design: 11, 12, 13, 14, 15, 16, 18, 20, 22, 26, 33, 44. Weights 400/500/600 (conflict 1). Letter-spacing is negative on large numerals: `-.2` to `-1px` — capture it, it matters at 44px.

**Spacing** — screen padding 18 horizontal, 108 bottom (clears the 84px nav). List rows: 66 (market), 70 (portfolio). Icon buttons 38×38. Avatars 40 (list), 26 (detail header), 36 (sheet), 52 (settings profile).

## Theme controller

- A Riverpod `Notifier` holding the active theme.
- Persist the choice to Hive so it survives restart; read it during startup and pass the initial value in, so the app never flashes the wrong theme on launch.
- Expose a provider the Settings screen ([10](10-settings.md)) drives and `MaterialApp` watches.

## Sentence case

All UI copy is sentence case ("Add to portfolio", "Couldn't load market"). Don't title-case labels.

## Tests

- `AppColors.lerp` and `copyWith` behave (no field dropped).
- Both `ThemeData`s expose an `AppColors` with all ten tokens non-null and distinct per theme.
- Theme controller: default is A; toggling persists; a restart with a persisted B starts on B.
- Derived helpers return the expected alpha/blend for a known input.

## Acceptance criteria

- [ ] All 20 values match the table byte-for-byte.
- [ ] Zero hex literals outside `core/theme/`. Grep to prove it.
- [ ] Theme switch rebuilds the whole app with no restart and no flash.
- [ ] Choice survives a cold start.
- [ ] `flutter analyze` + `flutter test` clean.

## Files touched

`lib/core/theme/app_colors.dart`, `app_theme.dart`, `theme_controller.dart`, `lib/core/constants/*` (radius, spacing, typography), `lib/main.dart` (wire), `test/core/theme/*`
