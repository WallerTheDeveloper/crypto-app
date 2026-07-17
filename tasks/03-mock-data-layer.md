# 03 · Mock data layer

**Depends on:** [00](00-project-setup.md) · **Blocks:** [04](04-app-shell-nav.md) and every screen

The whole MVP runs on mock data. **This task is where "mock" is allowed to exist and nowhere else.** Build it so that swapping in CoinGecko/Binance/Firestore later means writing new data sources and re-pointing one provider each — with zero changes above the repository line.

Layering per `CLAUDE.md`: `presentation → domain ← data`. `domain` is pure Dart — no Flutter, no Hive, no `dart:ui`. If a file in `domain/` imports `package:flutter`, the task is not done.

## Domain entities

Immutable (`const` ctor, final fields, `copyWith`, value equality). Currency-agnostic — entities hold raw numbers, formatting happens at the edge.

```
Coin        id, name, ticker, glyph, brandColor(int), price, change24hPct,
            circulatingSupply, allTimeHigh, volume24h, spark(List<double>)
Holding     coinId, amount, averageBuyPrice
Alert       id, coinId, direction(AlertDirection.above|below), targetPrice, isEnabled
PricePoint  index/timestamp, value
UserPrefs   themeId, currency(Currency.usd|eur), notificationsEnabled
```

Derived values (`value`, `costBasis`, `profitLoss`, `profitLossPct`, `marketCap`) are computed getters or use cases — never stored fields that can drift.

`brandColor` as `int` keeps `domain` free of `dart:ui`; presentation wraps it in `Color`.

## Repository interfaces (domain)

Keep them small and purpose-specific — interface segregation, one per feature:

```
MarketRepository     watchCoins() / getCoins() ; getCoin(id) ; getPriceSeries(id, range)
PortfolioRepository  watchHoldings() ; addHolding(...) ; removeHolding(...)
AlertsRepository     watchAlerts() ; addAlert(...) ; setAlertEnabled(id, bool) ; removeAlert(...)
PrefsRepository      watchPrefs() ; setTheme(...) ; setCurrency(...) ; setNotifications(...)
```

Reads that change over time are **streams** — live prices are a websocket later, and portfolio/alerts are Firestore later. Getting this shape right now is the entire point of the task; a `Future`-only interface will have to be rewritten.

## Failures

Typed failures in `core/error/` — a sealed class over `NetworkFailure`, `NotFoundFailure`, `CacheFailure`, `UnknownFailure`, each carrying a user-facing message. Data sources throw; repositories catch and convert. **No raw exception ever reaches the UI.** The error state's copy comes from the failure ("Couldn't load market", "Couldn't sync portfolio").

## Fixtures — copy exactly from the design

Eight coins, from `COINS` in the `.dc.html`. These exact values are what the design was drawn against:

| id | name | ticker | glyph | price | change | color | supply | ath | vol |
|---|---|---|---|---|---|---|---|---|---|
| btc | Bitcoin | BTC | ₿ | 64210.33 | +2.4 | #F7931A | 19.72e6 | 73800 | 28.4e9 |
| eth | Ethereum | ETH | Ξ | 3125.88 | -1.2 | #627EEA | 120.3e6 | 4878 | 14.1e9 |
| sol | Solana | SOL | S | 148.22 | +5.6 | #14B8A6 | 462e6 | 260 | 3.2e9 |
| xrp | XRP | XRP | X | 0.5821 | -0.4 | #3B4A54 | 55.1e9 | 3.84 | 1.8e9 |
| ada | Cardano | ADA | A | 0.446 | +1.1 | #0F5FE0 | 35.6e9 | 3.09 | 0.62e9 |
| doge | Dogecoin | DOGE | Ð | 0.1523 | +8.3 | #C2A633 | 143e9 | 0.73 | 1.1e9 |
| avax | Avalanche | AVAX | A | 36.74 | -2.7 | #E84142 | 396e6 | 146 | 0.44e9 |
| link | Chainlink | LINK | L | 14.82 | +3.2 | #2A5ADA | 617e6 | 52.7 | 0.51e9 |

Spark arrays (12 points each) are in the design's `COINS` — copy them verbatim.

Seed holdings (`HOLD`): `btc 0.42 @ 52000` · `eth 3.1 @ 2760` · `sol 24 @ 96` · `link 120 @ 11.4`

Seed alerts (`ALERTS`): `btc above 70000` **on** · `eth below 2800` **off** · `sol above 160` **on**

Seeds are first-run only. Once the user edits, their data wins — never re-seed over it.

## Mock data source

`MockMarketDataSource` etc. in `data/`, behind the same interfaces the real ones will implement.

**Artificial latency is required**, not a nicety: without it, skeletons never appear and the loading state is untestable. 600–900ms on reads.

Add a `MockConfig` (latency, `failureRate`/`forceFailure`) exposed as an overridable provider. This is how [11](11-verification.md) reaches all four states and how tests force the error path. It replaces the prototype's toolbar state-selector — but as a debug/test seam, **not** as UI.

### Price series generator

The design generates chart data deterministically. Port it exactly so charts are stable across rebuilds:

- `hash(id + range)` — FNV-1a 32-bit: `h = 2166136261`; per char `h ^= c; h = (h * 16777619) & 0xFFFFFFFF`.
- `rng(seed)` — the prototype's mulberry32 variant. Dart has no `Math.imul`; multiply then mask to 32 bits, and mind that Dart ints are 64-bit — mask after every multiply or the sequence diverges.
- Point counts by range: `24h → 30`, `7d → 40`, `30d → 44`, `1y → 48`.
- `trend = (coin.change / 100) * 3 / n`; start `v = 0.5`; each step `v += (r() - 0.5) * 0.11 + trend`.

Unit-test the generator against values captured from the prototype — this is easy to get subtly wrong and the drift is invisible until charts look off.

## Hive persistence

Boxes: `holdings`, `alerts`, `prefs`. Market data caches to a `market_cache` box.

**Cache-then-network** (`CLAUDE.md`): repository emits the cached value immediately, then refreshes from the "network" (mock source) and emits again. With mock latency this makes the pattern real and testable now, so the CoinGecko swap is a data-source change only.

Store JSON maps via `toJson`/`fromJson` on the **data-layer models** — no codegen, no adapters. DTOs live in `data/`, entities in `domain/`; map at the repository boundary. Don't let a Hive-shaped map reach a widget.

Writes are copy-on-write: build the new list/entity, persist, emit. Never mutate in place.

## Formatting

`core/utils/` — these are pure functions and heavily used, so test them hard. Ported from the design's `fmt`/`big`/`compact`:

- **`fmt(n)`** — multiply by rate; `|x| >= 1000` → grouped, 2dp (`$64,210.33`); `|x| >= 1` → 2dp (`$36.74`); else 4dp (`$0.5821`). Prefix `$` or `€`.
- **`big(n)`** — `>= 1e9` → `$28.40B`; `>= 1e6` → `$1.26M`; `>= 1e3` → `$1.26K`; else 2dp. (Note: unlike `fmt`, the design's `big` doesn't take absolute value — negatives fall through to the 2dp branch. Port as-is.)
- **`compact(n)`** — `>= 1e9` → `19.72B`; `>= 1e6` → `19.72M`; else grouped. No symbol; used for supply.
- **`changePct(n)`** — `(+|-)` then 1dp then `%`.
- **Currency:** USD rate 1.0, EUR rate **0.92**, symbols `$`/`€`. A hardcoded rate is correct for the MVP — real FX is post-MVP. Keep it a named constant, not a literal in a function.

Use `intl` for grouping; match `en_US` (the prototype's `toLocaleString('en-US')`) so EUR still groups with commas. If that reads wrong to the owner, that's a product call, not a silent fix.

## Providers

Expose data sources, repositories and use cases as providers so tests can override any layer. Repository providers return the **interface** type — a screen must not be able to see `MockMarketRepositoryImpl`.

## Tests

- Formatters across every branch boundary: 999.99/1000, 0.99/1, negatives, zero, both currencies.
- Series generator matches captured prototype output for a few `(id, range)` pairs.
- Portfolio math: `value`, `costBasis`, `profitLoss`, `profitLossPct` — including a loss and a zero-cost guard.
- Repository maps DTO→entity and exception→typed failure.
- Cache-then-network emits twice: cached first, then fresh.
- Hive round-trip for holdings/alerts/prefs; seeds apply on first run only.
- `MockConfig.forceFailure` produces the failure, not a crash.
- **Architecture test:** assert no file under `features/*/domain/` imports Flutter, Hive, or `dart:ui`. Cheap to write, catches the one mistake that quietly destroys the layering.

## Acceptance criteria

- [ ] `domain` is pure Dart, enforced by a test.
- [ ] Fixtures match the design exactly, including spark arrays.
- [ ] Read interfaces are stream-based.
- [ ] Mock latency makes skeletons visible on a real run.
- [ ] All four states reachable via `MockConfig`.
- [ ] Holdings/alerts/prefs survive restart; seeds don't overwrite user data.
- [ ] Nothing above `data/` mentions Hive or "mock".
- [ ] `flutter analyze` + `flutter test` clean; this task's coverage ≥ 90% (it's pure logic — no excuse).

## Files touched

`lib/core/error/*`, `lib/core/utils/*` (formatters, series generator), `lib/features/*/domain/**`, `lib/features/*/data/**`, `test/core/**`, `test/features/*/data/**`
