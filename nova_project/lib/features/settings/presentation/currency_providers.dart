import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency.dart';
import '../data/prefs_providers.dart';

/// Shared read-side access to the active display [Currency].
///
/// Currency is chosen in Settings (task 10) but read everywhere prices are
/// formatted (market, coin detail, portfolio). It is derived from the prefs
/// stream so a change in Settings updates every screen live, with no reload.
///
/// [currencyStreamProvider] carries the raw `AsyncValue`; [currencyProvider] is
/// the convenience most widgets want — a plain [Currency] that falls back to
/// [Currency.usd] until the first prefs emission.

final currencyStreamProvider = StreamProvider<Currency>((ref) {
  return ref.watch(prefsRepositoryProvider).watchPrefs().map((p) => p.currency);
});

final currencyProvider = Provider<Currency>((ref) {
  return ref
      .watch(currencyStreamProvider)
      .maybeWhen(data: (currency) => currency, orElse: () => Currency.usd);
});
