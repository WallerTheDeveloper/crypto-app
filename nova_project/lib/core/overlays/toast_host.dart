import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_spacing.dart';
import '../widgets/app_toast.dart';
import 'toast_controller.dart';

/// Renders the current toast above everything else, [AppSpacing.toastBottomInset]
/// off the bottom and centered. Owns no timing: the [AppToast] it renders owns
/// its own dwell, animation and dispose-safe cleanup; this host only decides
/// *what* shows, keyed by [ToastMessage.seq] so a replacement swaps in fresh.
class ToastHost extends ConsumerWidget {
  const ToastHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toast = ref.watch(toastControllerProvider);
    if (toast == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.toastBottomInset),
        child: AppToast(
          key: ValueKey(toast.seq),
          message: toast.text,
          onDismissed: () =>
              ref.read(toastControllerProvider.notifier).dismiss(toast.seq),
        ),
      ),
    );
  }
}
