import 'package:flutter/material.dart';

/// A text widget that truncates to [maxLines] with a tappable "more" link,
/// and expands/collapses on tap.
class ExpandableSummaryText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;

  const ExpandableSummaryText({
    super.key,
    required this.text,
    this.style,
    this.maxLines = 2,
  });

  @override
  State<ExpandableSummaryText> createState() => _ExpandableSummaryTextState();
}

class _ExpandableSummaryTextState extends State<ExpandableSummaryText> {
  bool _expanded = false;
  bool _hasOverflow = false;

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? DefaultTextStyle.of(context).style;
    final linkStyle = style.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Measure whether the text overflows at maxLines.
        final textSpan = TextSpan(text: widget.text, style: style);
        final tp = TextPainter(
          text: textSpan,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final overflows = tp.didExceedMaxLines;

        // Schedule state update if overflow status changed.
        if (overflows != _hasOverflow) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _hasOverflow = overflows);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text,
              style: style,
              maxLines: _expanded ? null : widget.maxLines,
              overflow:
                  _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (_hasOverflow && !_expanded)
              GestureDetector(
                onTap: () => setState(() => _expanded = true),
                child: Text('more', style: linkStyle),
              ),
            if (_expanded)
              GestureDetector(
                onTap: () => setState(() => _expanded = false),
                child: Text('less', style: linkStyle),
              ),
          ],
        );
      },
    );
  }
}
