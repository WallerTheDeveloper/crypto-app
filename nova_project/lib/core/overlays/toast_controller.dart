import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The message currently requested to show, tagged with a monotonic [seq].
///
/// [seq] changes on every [ToastController.show] — even for identical text —
/// so the host can key the toast widget by it. A new key rebuilds the toast
/// fresh, which is what "a new toast replaces the current one and restarts the
/// timer" means in practice: the old toast is disposed (its timer cancelled)
/// and a new one starts its dwell from zero.
@immutable
class ToastMessage {
  const ToastMessage(this.text, this.seq);

  final String text;
  final int seq;

  @override
  bool operator ==(Object other) =>
      other is ToastMessage && other.text == text && other.seq == seq;

  @override
  int get hashCode => Object.hash(text, seq);
}

/// The toast host's controller. Holds the current message (or null); the
/// timing, enter/exit animation and dispose-safe leak guard live in the
/// `AppToast` widget the host renders, so replacement here is just a new [seq].
class ToastController extends Notifier<ToastMessage?> {
  int _seq = 0;

  @override
  ToastMessage? build() => null;

  /// Shows [text], replacing any current toast and restarting its dwell.
  void show(String text) => state = ToastMessage(text, ++_seq);

  /// Clears the toast if [seq] is still the one showing. Guarded so a stale
  /// dismissal from a toast that was already replaced can't clear its successor.
  void dismiss(int seq) {
    if (state?.seq == seq) state = null;
  }
}

final toastControllerProvider =
    NotifierProvider<ToastController, ToastMessage?>(ToastController.new);
