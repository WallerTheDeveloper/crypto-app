import 'package:flutter/material.dart';

import '../constants/app_radii.dart';
import '../theme/app_colors.dart';

/// A 46×27 pill switch: `accent` track when on, `borderStrong` when off, with a
/// 21×21 white knob that slides 3→22 over 200ms. Used by alerts and the
/// notifications preference.
class ToggleSwitch extends StatelessWidget {
  const ToggleSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  static const double _trackWidth = 46;
  static const double _trackHeight = 27;
  static const double _knob = 21;
  static const Duration _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeInOut,
        width: _trackWidth,
        height: _trackHeight,
        decoration: BoxDecoration(
          color: value ? colors.accent : colors.borderStrong,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: _duration,
              curve: Curves.easeInOut,
              top: 3,
              left: value ? 22 : 3,
              child: Container(
                width: _knob,
                height: _knob,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
