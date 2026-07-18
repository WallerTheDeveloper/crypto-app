import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../theme/app_colors.dart';
import '../widgets/icons/app_icon.dart';
import 'nav_controller.dart';

/// The `blur(12px)` behind the nav's 92% fill, matching the design's
/// `backdrop-filter`. Content scrolls under the bar and shows through it.
const double _blurSigma = 12;

/// One entry in the bar: its tab, icon and label.
class _NavItem {
  const _NavItem(this.tab, this.icon, this.label);
  final NavTab tab;
  final AppIconType icon;
  final String label;
}

const List<_NavItem> _items = [
  _NavItem(NavTab.market, AppIconType.market, 'Market'),
  _NavItem(NavTab.portfolio, AppIconType.portfolio, 'Portfolio'),
  _NavItem(NavTab.alerts, AppIconType.alerts, 'Alerts'),
  _NavItem(NavTab.settings, AppIconType.settings, 'Settings'),
];

/// The pinned bottom nav: a `navSurface` (s1 at 92%) fill over a 12px blur with
/// a 1px top rule, four equal-flex items, and a bottom inset that tracks the
/// device's home-indicator safe area rather than a hardcoded 24.
class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(navControllerProvider);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.navSurface,
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: AppSpacing.navPaddingTop,
              left: AppSpacing.navPaddingH,
              right: AppSpacing.navPaddingH,
              bottom: bottomInset,
            ),
            child: SizedBox(
              height: AppSpacing.navContentHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in _items)
                    Expanded(
                      child: _NavButton(
                        item: item,
                        active: state.isTabActive(item.tab),
                        onTap: () => ref
                            .read(navControllerProvider.notifier)
                            .selectTab(item.tab),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Icon and label both take the active/inactive color.
    final color = active ? colors.accent : colors.muted;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 24,
            child: Center(child: AppIcon(item.icon, color: color)),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              color: color,
              fontSize: AppTypography.s11,
              fontWeight: AppTypography.medium,
            ),
          ),
        ],
      ),
    );
  }
}
