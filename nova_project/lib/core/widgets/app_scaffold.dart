import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../theme/app_colors.dart';

/// Shared chrome for every screen: `bg` fill, a top [SafeArea] (the real status
/// bar — never the design's fake 9:41 bar), 18px horizontal padding, and a
/// bounce-scrolling view whose content clears the 108px nav gap and scrolls
/// *under* the translucent nav (no bottom inset). The scrollbar is hidden to
/// match the design.
///
/// Most screens pass a [title] (rendered 22px/600); Market passes a custom
/// [header] (logo + search + avatar) instead. Content is supplied as
/// [children], laid out in a start-aligned column below the header.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    this.title,
    this.header,
    this.children = const [],
    super.key,
  }) : assert(
         title != null || header != null,
         'AppScaffold needs a title or a header.',
       );

  /// Plain screen title. Ignored when [header] is supplied.
  final String? title;

  /// Custom header widget (Market). Overrides [title] when set.
  final Widget? header;

  /// Screen content below the header.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.bg,
      child: SafeArea(
        bottom: false,
        child: ScrollConfiguration(
          behavior: const _NoScrollbarBehavior(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              0,
              AppSpacing.screenH,
              AppSpacing.screenBottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header ?? _ScreenTitle(title!),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScreenTitle extends StatelessWidget {
  const _ScreenTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 18),
      child: Text(
        title,
        style: TextStyle(
          color: context.colors.text,
          fontSize: AppTypography.s22,
          fontWeight: AppTypography.semibold,
          letterSpacing: AppTypography.trackTitle,
        ),
      ),
    );
  }
}

/// Hides the scrollbar and the overscroll glow — the design's `.scrl` shows
/// neither — while leaving iOS-style bounce to the view's physics.
class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, details) => child;

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, details) =>
      child;
}
