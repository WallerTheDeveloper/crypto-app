import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/navigation/nav_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/coin_avatar.dart';
import '../../../../core/widgets/sparkline.dart';
import '../../../settings/presentation/currency_providers.dart';
import '../../domain/entities/coin.dart';

/// One 66px market row: avatar, name/ticker, sparkline, then price and 24h
/// change. Tapping opens coin detail. Price and change follow the active
/// currency; the change text and sparkline are always `gain`/`loss`, never
/// `accent`.
class MarketCoinRow extends ConsumerWidget {
  const MarketCoinRow({required this.coin, super.key});

  final Coin coin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final currency = ref.watch(currencyProvider);
    final up = coin.change24hPct >= 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            ref.read(navControllerProvider.notifier).openDetail(coin.id),
        child: Container(
          height: AppSpacing.marketRow,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          child: Row(
            children: [
              CoinAvatar(
                color: Color(coin.brandColor),
                glyph: coin.glyph,
                size: AppSpacing.avatarList,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: AppTypography.s15,
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coin.ticker,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.muted,
                        fontSize: AppTypography.s12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Sparkline(values: coin.spark, positive: up),
              const SizedBox(width: 13),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 88),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.fmt(coin.price, currency),
                      style: TextStyle(
                        color: colors.text,
                        fontSize: AppTypography.s15,
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.changePct(coin.change24hPct),
                      style: TextStyle(
                        color: up ? colors.gain : colors.loss,
                        fontSize: AppTypography.s12,
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
