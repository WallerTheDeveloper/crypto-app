import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// Riverpod 3 exposes `Override` only through this entry point.
import 'package:riverpod/misc.dart' show Override;
import 'package:nova_project/core/navigation/nav_controller.dart';
import 'package:nova_project/core/theme/app_theme.dart';
import 'package:nova_project/core/utils/currency.dart';
import 'package:nova_project/core/widgets/app_icon_button.dart';
import 'package:nova_project/core/widgets/icons/app_icon.dart';
import 'package:nova_project/features/market/data/market_providers.dart';
import 'package:nova_project/features/market/domain/entities/coin.dart';
import 'package:nova_project/features/market/domain/entities/market_sort.dart';
import 'package:nova_project/features/market/presentation/market_screen.dart';
import 'package:nova_project/features/market/presentation/providers/market_sort_notifier.dart';
import 'package:nova_project/features/market/presentation/widgets/market_coin_row.dart';
import 'package:nova_project/features/market/presentation/widgets/market_list_skeleton.dart';
import 'package:nova_project/features/market/presentation/widgets/market_search_field.dart';
import 'package:nova_project/features/portfolio/presentation/providers/portfolio_summary_provider.dart';
import 'package:nova_project/features/settings/presentation/currency_providers.dart';

import '../../../support/market_test_support.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  AppTheme theme = AppTheme.dark,
  List<Override> overrides = const [],
}) async {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppThemes.of(theme),
        // In the app, NavShell's Scaffold is the single Material ancestor for
        // every screen; mirror that here so widgets like the search field
        // (which needs Material) build as they do in production.
        home: const Scaffold(body: MarketScreen()),
      ),
    ),
  );
  return container;
}

List<String> _rowNames(WidgetTester tester) => tester
    .widgetList<MarketCoinRow>(find.byType(MarketCoinRow))
    .map((row) => row.coin.name)
    .toList();

Finder _closeButton() =>
    find.byWidgetPredicate((w) => w is AppIcon && w.type == AppIconType.close);

void main() {
  group('populated', () {
    testWidgets(
      'renders all eight coins with price and change, in both themes',
      (tester) async {
        for (final theme in AppTheme.values) {
          await _pump(tester, theme: theme, overrides: marketScreenOverrides());
          await tester.pumpAndSettle();

          expect(find.byType(MarketCoinRow), findsNWidgets(8));
          expect(find.text('Bitcoin'), findsOneWidget);
          expect(find.text('BTC'), findsOneWidget);
          expect(find.text(r'$64,210.33'), findsOneWidget);
          expect(find.text('+2.4%'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets('change text is gain/loss, never accent', (tester) async {
      await _pump(tester, overrides: marketScreenOverrides());
      await tester.pumpAndSettle();

      final colors = AppThemes.darkColors;
      final gain = tester.widget<Text>(find.text('+2.4%')); // BTC, up
      final loss = tester.widget<Text>(find.text('-1.2%')); // ETH, down

      expect(gain.style!.color, colors.gain);
      expect(loss.style!.color, colors.loss);
      expect(gain.style!.color, isNot(colors.accent));
    });
  });

  group('sorting', () {
    testWidgets('market cap is the default; Gainers reorders by 24h change', (
      tester,
    ) async {
      await _pump(tester, overrides: marketScreenOverrides());
      await tester.pumpAndSettle();

      expect(_rowNames(tester).first, 'Bitcoin'); // biggest cap

      await tester.tap(find.text('Gainers'));
      await tester.pumpAndSettle();
      expect(_rowNames(tester).first, 'Dogecoin'); // +8.3%, biggest gainer
    });

    testWidgets('Watchlist is inert — no active change, no reorder', (
      tester,
    ) async {
      final container = await _pump(tester, overrides: marketScreenOverrides());
      await tester.pumpAndSettle();
      final before = _rowNames(tester);

      await tester.tap(find.text('Watchlist'));
      await tester.pumpAndSettle();

      expect(container.read(activeSortProvider), MarketSort.marketCap);
      expect(_rowNames(tester), before);
    });

    testWidgets('the active chip is painted with accent in both themes', (
      tester,
    ) async {
      for (final theme in AppTheme.values) {
        await _pump(tester, theme: theme, overrides: marketScreenOverrides());
        await tester.pumpAndSettle();

        final material = tester.widget<Material>(
          find
              .ancestor(
                of: find.text('Market cap'),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(material.color, AppThemes.colorsOf(theme).accent);
      }
    });
  });

  group('search', () {
    testWidgets(
      'filters by name and ticker, then clears back to the full list',
      (tester) async {
        await _pump(tester, overrides: marketScreenOverrides());
        await tester.pumpAndSettle();

        // Open search — the header becomes the field.
        await tester.tap(find.byType(AppIconButton));
        await tester.pumpAndSettle();
        expect(find.byType(MarketSearchField), findsOneWidget);

        // By name, lowercase.
        await tester.enterText(find.byType(TextField), 'bitcoin');
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(_rowNames(tester), ['Bitcoin']);

        // By ticker, uppercase.
        await tester.enterText(find.byType(TextField), 'ETH');
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(_rowNames(tester), ['Ethereum']);

        // No match → empty state.
        await tester.enterText(find.byType(TextField), 'zzz');
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(find.text('No results'), findsOneWidget);
        expect(find.byType(MarketCoinRow), findsNothing);

        // Dismiss → full list restored, header back.
        await tester.tap(_closeButton());
        await tester.pumpAndSettle();
        expect(find.byType(MarketCoinRow), findsNWidgets(8));
        expect(find.byType(MarketSearchField), findsNothing);
      },
    );
  });

  group('loading', () {
    testWidgets('covers the strip, chips and six rows', (tester) async {
      await _pump(
        tester,
        overrides: [
          marketRepositoryProvider.overrideWithValue(
            FakeMarketRepository(
              (_) => Stream<List<Coin>>.fromFuture(
                Completer<List<Coin>>().future, // never completes
              ),
            ),
          ),
          portfolioSummaryProvider.overrideWithValue(
            const AsyncValue.loading(),
          ),
          currencyStreamProvider.overrideWith(
            (ref) => Stream.value(Currency.usd),
          ),
        ],
      );
      // A single frame — the shimmer animates forever, so never settle.
      await tester.pump();

      expect(find.byType(MarketListSkeleton), findsOneWidget);
      expect(find.byType(MarketSkeletonRow), findsNWidgets(6));
    });
  });

  group('error', () {
    testWidgets('shows a message and a Retry that re-runs the fetch', (
      tester,
    ) async {
      final repo = FakeMarketRepository(
        (call) => call == 0
            ? Stream<List<Coin>>.error(Exception('boom'))
            : Stream<List<Coin>>.value(sampleCoins),
      );
      await _pump(
        tester,
        overrides: [
          marketRepositoryProvider.overrideWithValue(repo),
          portfolioSummaryProvider.overrideWithValue(
            AsyncValue.data(sampleSummary()),
          ),
          currencyStreamProvider.overrideWith(
            (ref) => Stream.value(Currency.usd),
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load market"), findsOneWidget);
      expect(find.byType(MarketCoinRow), findsNothing);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.byType(MarketCoinRow), findsNWidgets(8));
      expect(repo.watchCount, 2); // genuinely re-fetched, not a local flip
    });
  });

  group('navigation', () {
    testWidgets('tapping a row opens that coin\'s detail', (tester) async {
      final container = await _pump(tester, overrides: marketScreenOverrides());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bitcoin'));
      await tester.pumpAndSettle();

      expect(container.read(navControllerProvider).detailCoinId, 'btc');
    });

    testWidgets('tapping the snapshot strip switches to Portfolio', (
      tester,
    ) async {
      final container = await _pump(tester, overrides: marketScreenOverrides());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Portfolio value'));
      await tester.pumpAndSettle();

      expect(container.read(navControllerProvider).tab, NavTab.portfolio);
    });
  });

  group('currency', () {
    testWidgets('reprices the list live, without re-fetching', (tester) async {
      final repo = FakeMarketRepository.always(sampleCoins);
      final currency = StreamController<Currency>();
      addTearDown(currency.close);

      await _pump(
        tester,
        overrides: [
          marketRepositoryProvider.overrideWithValue(repo),
          portfolioSummaryProvider.overrideWithValue(
            AsyncValue.data(sampleSummary()),
          ),
          currencyStreamProvider.overrideWith((ref) => currency.stream),
        ],
      );

      currency.add(Currency.usd);
      await tester.pumpAndSettle();
      expect(find.text(r'$64,210.33'), findsOneWidget);

      currency.add(Currency.eur);
      await tester.pumpAndSettle();
      expect(find.text('€59,073.50'), findsOneWidget); // 64210.33 × 0.92
      expect(find.text(r'$64,210.33'), findsNothing);
      expect(repo.watchCount, 1); // list was not reloaded
    });
  });
}
