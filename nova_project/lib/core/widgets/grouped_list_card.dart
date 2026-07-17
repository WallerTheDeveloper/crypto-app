import 'package:flutter/material.dart';

import '../constants/app_radii.dart';
import '../theme/app_colors.dart';

/// A radius-16 card that stacks rows with 1px `border` dividers between them and
/// no divider after the last. Rows supply their own padding; the card clips
/// them to its rounded corners. Settings' preference groups use this.
class GroupedListCard extends StatelessWidget {
  const GroupedListCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadii.card);

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) {
        rows.add(Divider(height: 1, thickness: 1, color: colors.border));
      }
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.s1,
        borderRadius: radius,
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(mainAxisSize: MainAxisSize.min, children: rows),
      ),
    );
  }
}
