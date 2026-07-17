import 'package:flutter/material.dart';

import '../constants/app_radii.dart';
import '../constants/app_typography.dart';
import '../theme/app_colors.dart';

/// One choice in a [SegmentedControl].
@immutable
class SegmentData<T> {
  const SegmentData({required this.value, required this.label});

  final T value;
  final String label;
}

/// The two visual presets from the design.
enum SegmentedStyle {
  /// Pill track over `s2`, fully-rounded segments — Settings' theme/currency.
  pill,

  /// Radius-12 track over `s1`, radius-9 segments that flex to fill — the
  /// coin-detail range toggle.
  inset,
}

/// A pill/segmented selector, generic over the item type.
///
/// Exactly one segment paints active (`accent` fill + white); the rest are
/// transparent with `muted` labels. The active fill cross-fades over ~150ms.
/// It reports the tapped value through [onChanged] and holds no state itself.
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    required this.segments,
    required this.value,
    required this.onChanged,
    this.style = SegmentedStyle.pill,
    this.expand,
    super.key,
  });

  final List<SegmentData<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;
  final SegmentedStyle style;

  /// Whether segments stretch to fill the width. Defaults to true for
  /// [SegmentedStyle.inset] (flex range toggle) and false for [pill].
  final bool? expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inset = style == SegmentedStyle.inset;
    final expanded = expand ?? inset;

    final trackRadius = BorderRadius.circular(
      inset ? AppRadii.control : AppRadii.pill,
    );
    final segRadius = BorderRadius.circular(
      inset ? AppRadii.chartBox : AppRadii.pill,
    );
    final segPadding = inset
        ? const EdgeInsets.symmetric(vertical: 9)
        : const EdgeInsets.symmetric(vertical: 7, horizontal: 16);

    Widget wrap(Widget child) => expanded ? Expanded(child: child) : child;

    return Container(
      padding: EdgeInsets.all(inset ? 4 : 3),
      decoration: BoxDecoration(
        color: inset ? colors.s1 : colors.s2,
        borderRadius: trackRadius,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (final segment in segments)
            wrap(
              _Segment(
                label: segment.label,
                active: segment.value == value,
                radius: segRadius,
                padding: segPadding,
                onTap: () => onChanged(segment.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.radius,
    required this.padding,
    required this.onTap,
  });

  final String label;
  final bool active;
  final BorderRadius radius;
  final EdgeInsets padding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? colors.accent : Colors.transparent,
          borderRadius: radius,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active
                ? Theme.of(context).colorScheme.onPrimary
                : colors.muted,
            fontSize: AppTypography.s13,
            fontWeight: AppTypography.medium,
          ),
        ),
      ),
    );
  }
}
