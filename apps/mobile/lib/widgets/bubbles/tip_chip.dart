import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/messages.dart';
import '../../theme/app_theme.dart';

/// A gentle, non-intrusive chip for informational tips (e.g. "no git detected").
///
/// Visually similar to [SystemChip] but with an info icon. Designed to inform
/// without alarming — softer than [ErrorBubble]'s warning style.
class TipChip extends StatelessWidget {
  final SystemMessage message;
  const TipChip({super.key, required this.message});

  String _text(BuildContext context) => switch (message.tipCode) {
    'git_not_available' => AppLocalizations.of(context)!.tipGitNotAvailable,
    _ => message.subtype,
  };

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 14, color: appColors.subtleText),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _text(context),
                style: TextStyle(fontSize: 12, color: appColors.subtleText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
