import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the market search field is open, and the (debounced) query it filters
/// by. [active] drives the header swap; [query] drives filtering and the empty
/// state.
@immutable
class MarketSearchState {
  const MarketSearchState({this.active = false, this.query = ''});

  final bool active;
  final String query;

  MarketSearchState copyWith({bool? active, String? query}) =>
      MarketSearchState(
        active: active ?? this.active,
        query: query ?? this.query,
      );

  @override
  bool operator ==(Object other) =>
      other is MarketSearchState &&
      other.active == active &&
      other.query == query;

  @override
  int get hashCode => Object.hash(active, query);
}

/// How long typing settles before the list re-filters. Keeps filtering off the
/// per-keystroke path.
const Duration _debounce = Duration(milliseconds: 250);

/// Owns the market search interaction: opening/closing the field and debouncing
/// the query. The text field itself holds the raw text; this notifier only
/// publishes the committed query the list filters on.
class MarketSearchController extends Notifier<MarketSearchState> {
  Timer? _timer;

  @override
  MarketSearchState build() {
    ref.onDispose(() => _timer?.cancel());
    return const MarketSearchState();
  }

  /// Opens the search field (swapping the header). Keeps any existing query.
  void open() {
    if (state.active) return;
    state = state.copyWith(active: true);
  }

  /// Closes the field and clears the query, restoring the full list.
  void close() {
    _timer?.cancel();
    state = const MarketSearchState();
  }

  /// Records typed [value], applying it after the debounce window.
  void setQuery(String value) {
    _timer?.cancel();
    _timer = Timer(_debounce, () {
      if (state.query != value) state = state.copyWith(query: value);
    });
  }
}

final marketSearchProvider =
    NotifierProvider<MarketSearchController, MarketSearchState>(
      MarketSearchController.new,
    );
