import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';

/// Which bottom sheet the shell is showing. [none] means no sheet is open.
enum SheetKind { none, addHolding, createAlert }

/// Drives which sheet is open. Any screen can request a sheet without owning
/// its chrome (the host in `sheet_host.dart` reacts to this).
class SheetController extends Notifier<SheetKind> {
  @override
  SheetKind build() => SheetKind.none;

  /// Opens [kind]. Passing [SheetKind.none] closes instead.
  void open(SheetKind kind) => state = kind;

  void close() => state = SheetKind.none;
}

final sheetControllerProvider = NotifierProvider<SheetController, SheetKind>(
  SheetController.new,
);

/// Builds the body of the open sheet. The host owns the chrome (scrim, panel,
/// grab handle, keyboard inset); the *content* is supplied here so the host
/// owns none of it.
///
/// Task 09 overrides this provider with the real add-holding / create-alert
/// forms. Until then it renders a titled placeholder so the chrome is
/// verifiable.
typedef SheetContentBuilder = Widget Function(BuildContext context, SheetKind kind);

final sheetContentBuilderProvider = Provider<SheetContentBuilder>((ref) {
  return (context, kind) => _PlaceholderSheetBody(kind: kind);
});

class _PlaceholderSheetBody extends StatelessWidget {
  const _PlaceholderSheetBody({required this.kind});

  final SheetKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = switch (kind) {
      SheetKind.addHolding => 'Add holding',
      SheetKind.createAlert => 'Set price alert',
      SheetKind.none => '',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(color: colors.muted, fontSize: 13),
      ),
    );
  }
}
