import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_radii.dart';
import '../theme/app_colors.dart';
import '../theme/overlay_tokens.dart';
import 'sheet_controller.dart';

// Panel metrics from the design (px). Named rather than inlined so no magic
// number lands in the layout.
const double _panelPadH = 20;
const double _panelPadTop = 8;
const double _panelPadBottom = 30;
const double _grabWidth = 40;
const double _grabHeight = 5;
const double _grabRadius = 3;
const EdgeInsets _grabMargin = EdgeInsets.only(top: 6, bottom: 18);

/// Hosts the bottom sheet: a tap-to-dismiss scrim and the animated panel. Owns
/// the chrome only — the body comes from [sheetContentBuilderProvider], so the
/// host holds no sheet content and any screen can open one via
/// [sheetControllerProvider].
class SheetHost extends ConsumerWidget {
  const SheetHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kind = ref.watch(sheetControllerProvider);
    if (kind == SheetKind.none) return const SizedBox.shrink();

    final content = ref.watch(sheetContentBuilderProvider);

    return Stack(
      children: [
        // Scrim — covers the whole screen (including the nav), tap to dismiss.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ref.read(sheetControllerProvider.notifier).close(),
            child: const ColoredBox(color: OverlayTokens.scrim),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          // A fresh panel per kind so its enter animation replays on switch.
          child: _SheetPanel(
            key: ValueKey(kind),
            child: content(context, kind),
          ),
        ),
      ],
    );
  }
}

/// The panel: `s2` fill, 26px top corners, a grab handle, and a `fadeUp` enter
/// (opacity 0→1 + 8px rise, 300ms). Lifts above the keyboard via `viewInsets`.
class _SheetPanel extends StatefulWidget {
  const _SheetPanel({required this.child, super.key});

  final Widget child;

  @override
  State<_SheetPanel> createState() => _SheetPanelState();
}

class _SheetPanelState extends State<_SheetPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final media = MediaQuery.of(context);

    final panel = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.s2,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet),
        ),
        border: Border(top: BorderSide(color: colors.borderStrong)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: _panelPadH,
          top: _panelPadTop,
          right: _panelPadH,
          // Design bottom padding, plus the home-indicator inset.
          bottom: _panelPadBottom + media.viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: _grabWidth,
                height: _grabHeight,
                margin: _grabMargin,
                decoration: BoxDecoration(
                  color: colors.borderStrong,
                  borderRadius: BorderRadius.circular(_grabRadius),
                ),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _controller.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _controller.value) * 8),
          child: child,
        ),
      ),
      // Keyboard inset lives here: pad the panel up by the keyboard height so
      // the sheet's text field (task 09) stays visible.
      child: Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: panel,
      ),
    );
  }
}
