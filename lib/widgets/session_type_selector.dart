import 'package:flutter/material.dart';
import '../bloc/timer_bloc.dart';
import '../theme/app_theme.dart';

class SessionTypeSelector extends StatelessWidget {
  final SessionType selected;
  final ValueChanged<SessionType> onChanged;

  const SessionTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  Color _accentFor(SessionType t) {
    switch (t) {
      case SessionType.focus:
        return AppTheme.focusAccent;
      case SessionType.shortBreak:
        return AppTheme.shortBreakAccent;
      case SessionType.longBreak:
        return AppTheme.longBreakAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: SessionType.values.map((type) {
          final isSelected = type == selected;
          final accent = _accentFor(type);
          return GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? accent.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(color: accent.withOpacity(0.4))
                    : Border.all(color: Colors.transparent),
              ),
              child: Text(
                type.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? accent : AppTheme.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
