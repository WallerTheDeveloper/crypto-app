import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_radii.dart';
import '../constants/app_typography.dart';
import '../theme/app_colors.dart';
import 'icons/app_icon.dart';

/// The confirmation toast: `s2` pill with a `borderStrong` border, a `gain`
/// check disc and a short label.
///
/// It animates itself in (fade + 12px rise, 300ms), stays for [visibleDuration]
/// (2200ms), then animates out and calls [onDismissed]. The host in the app
/// shell decides *when* to show one and what it says; this widget owns the
/// lifecycle so it can be dropped anywhere.
class AppToast extends StatefulWidget {
  const AppToast({
    required this.message,
    this.onDismissed,
    this.visibleDuration = const Duration(milliseconds: 2200),
    super.key,
  });

  final String message;
  final VoidCallback? onDismissed;
  final Duration visibleDuration;

  @override
  State<AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<AppToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  Timer? _timer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.visibleDuration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissed) return;
    await _controller.reverse();
    if (!mounted) return;
    setState(() => _dismissed = true);
    widget.onDismissed?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _controller.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _controller.value) * 12),
          child: child,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.s2,
          borderRadius: BorderRadius.circular(AppRadii.inner),
          border: Border.all(color: colors.borderStrong),
          boxShadow: [
            BoxShadow(
              // Design shadow is a fixed rgba(0,0,0,.5) in both themes.
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              spreadRadius: -10,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.gain,
                  shape: BoxShape.circle,
                ),
                child: AppIcon(
                  AppIconType.check,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 13,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.message,
                style: TextStyle(
                  color: colors.text,
                  fontSize: AppTypography.s14,
                  fontWeight: AppTypography.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
