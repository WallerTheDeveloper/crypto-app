import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/icons/app_icon.dart';
import '../providers/market_search_notifier.dart';

/// The inline search input that replaces the market header while searching.
///
/// The design never draws this field — it only implies it via the header icon
/// and the "No results" empty state — so it is built to the same 38px height as
/// the icon button it grows from. It owns its text controller/focus, autofocuses
/// on open, reports (debounced) changes to [marketSearchProvider], and dismisses
/// via the trailing clear button.
class MarketSearchField extends ConsumerStatefulWidget {
  const MarketSearchField({super.key});

  @override
  ConsumerState<MarketSearchField> createState() => _MarketSearchFieldState();
}

class _MarketSearchFieldState extends ConsumerState<MarketSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadii.iconButton);

    return Container(
      height: AppSpacing.iconButton,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.s1,
        borderRadius: radius,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          AppIcon(AppIconType.search, color: colors.muted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              onChanged: (value) =>
                  ref.read(marketSearchProvider.notifier).setQuery(value),
              cursorColor: colors.accent,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                color: colors.text,
                fontSize: AppTypography.s15,
                fontWeight: AppTypography.regular,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search coins…',
                hintStyle: TextStyle(
                  color: colors.muted,
                  fontSize: AppTypography.s15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ref.read(marketSearchProvider.notifier).close(),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: AppIcon(AppIconType.close, color: colors.muted, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
