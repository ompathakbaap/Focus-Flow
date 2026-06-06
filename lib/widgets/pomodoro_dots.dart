import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PomodoroDots extends StatelessWidget {
  final int completed;
  final Color accentColor;
  final int total;

  const PomodoroDots({
    super.key,
    required this.completed,
    required this.accentColor,
    this.total = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isFilled = i < (completed % total == 0 && completed > 0
            ? total
            : completed % total);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isFilled ? 10 : 8,
          height: isFilled ? 10 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? accentColor : AppTheme.border,
            boxShadow: isFilled
                ? [BoxShadow(color: accentColor.withOpacity(0.5), blurRadius: 6)]
                : [],
          ),
        );
      }),
    );
  }
}
