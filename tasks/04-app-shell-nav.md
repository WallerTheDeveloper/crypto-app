# 04 · App shell & navigation

**Depends on:** [01](01-theme-tokens.md), [02](02-core-widgets.md), [03](03-mock-data-layer.md) · **Blocks:** all screens

The frame every screen lives in: bottom nav, screen switching, and the two overlay hosts (sheet, toast).

## Bottom nav

Pinned to the bottom, **84px** tall, padding `10px 8px 24px` (the 24 is the home-indicator inset — use `SafeArea`/`viewPadding` rather than a hardcoded 24 so it's right on every device). Fill `navSurface` (`s1` at 92%) over a **12px blur** — a real `BackdropFilter`, since the design's translucency is visible against scrolled content. 1px `border` top rule.

Four items, equal flex, icon (24px box) above an 11px/500 label: **Market · Portfolio · Alerts · Settings**. Active = `accent`, inactive = `muted`, icon and label both.

**Coin detail counts as Market** — `on = screen == k || (k == 'market' && screen == 'detail')`. The Market tab stays lit while a coin is open.

Screens pad `108px` at the bottom so content clears the nav. Content scrolls **under** it (that's what the blur is for) — don't inset the scroll view.

## Navigation

Four tabs plus coin detail pushed from Market. Detail has a back button returning to Market, and the nav stays visible over it.

`CLAUDE.md` locks no router. Recommendation: **`Navigator` + an `IndexedStack`** for the four tabs — keeps each tab's scroll position, which the design implies by treating detail as a Market sub-screen. Push detail as a route above the stack. Don't add `go_router` for five screens; if you think the MVP needs it, raise it rather than adding a routing dependency unilaterally.

Nav state is a Riverpod `Notifier`, not `setState` — it's shared with the nav bar and detail.

## Sheet host

The design's sheet ([09](09-sheets-and-toast.md)) is a bottom sheet with a scrim. Build the **host** here, content there:

- Scrim `rgba(5,3,15,.45)` covering the screen, tap-to-dismiss.
- Panel: `s2` fill, radius **26 top only**, 1px `borderStrong` top, padding `8px 20px 30px`.
- Grab handle: 40×5, radius 3, `borderStrong`, centered, margin `6 auto 18`.
- Enters with `fadeUp`: opacity 0→1 + 8px rise, **300ms** ease.
- Must sit above the nav and respect the keyboard inset — [09](09-sheets-and-toast.md) has a text field, so `viewInsets` handling belongs here.

A provider drives which sheet is open (`none | addHolding | createAlert`), so any screen can request one without owning it.

## Toast host

An overlay above everything (`z-index: 30` in the design), **100px** off the bottom, centered.

The toast widget is [02](02-core-widgets.md)'s. Here: a controller provider with `show(message)`, auto-dismiss at **2200ms**, and — matching the prototype's `clearTimeout` — a new toast **replaces** the current one and restarts the timer rather than queueing.

Guard against the classic leak: cancel the timer on dispose, and don't touch state after dispose.

## Screen scaffold

A shared scaffold so every screen agrees on chrome:

- `bg` background; `SafeArea` at the top (real status bar — do **not** rebuild the design's fake 9:41 bar).
- 18px horizontal padding, 108px bottom.
- Scroll view with **no visible scrollbar** (the design's `.scrl` hides it) and iOS-style bounce.
- Screen title: 22px/600, letter-spacing -0.4, padding `8px 2px 18px`. Market's header is custom (logo + search + avatar); the rest are a plain title.

## Tests

- Tapping each nav item switches screens; the tapped item is the only `accent` one.
- Opening detail keeps **Market** lit.
- Back from detail returns to Market with scroll position intact.
- Sheet host: opens on provider change, dismisses on scrim tap, animates in.
- Toast host: shows, auto-dismisses at 2200ms, second toast replaces the first and resets the timer.
- Timer is cancelled on dispose (no "setState after dispose" in test output).
- Nav renders correctly in both themes.

## Acceptance criteria

- [ ] Nav matches: 84px, blur, 92% fill, correct active colors.
- [ ] Detail keeps the Market tab active.
- [ ] Content scrolls under the nav with the blur visible.
- [ ] Sheet and toast hosts are reachable from any screen via provider, own no content.
- [ ] No hardcoded safe-area insets.
- [ ] Both themes verified.
- [ ] `flutter analyze` + `flutter test` clean.

## Files touched

`lib/core/widgets/app_scaffold.dart`, `lib/core/navigation/*` (shell, nav bar, nav notifier), `lib/core/overlays/*` (sheet host, toast host + controller), `lib/main.dart`, `test/core/navigation/*`
