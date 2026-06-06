import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatsChart extends StatefulWidget {
  final List<int> dailySessions; // last 7 days, index 0 = oldest
  final Color accentColor;

  const StatsChart({
    super.key,
    required this.dailySessions,
    required this.accentColor,
  });

  @override
  State<StatsChart> createState() => _StatsChartState();
}

class _StatsChartState extends State<StatsChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxVal = widget.dailySessions.isEmpty
        ? 1
        : widget.dailySessions.reduce((a, b) => a > b ? a : b);
    final today = DateTime.now().weekday - 1; // 0=Mon

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (i) {
            final count = i < widget.dailySessions.length
                ? widget.dailySessions[i]
                : 0;
            final heightFraction = maxVal == 0 ? 0.0 : count / maxVal;
            final isToday = i == today;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (count > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10,
                        color: isToday
                            ? widget.accentColor
                            : AppTheme.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  width: 28,
                  height: 80 * heightFraction * _animation.value + 4,
                  decoration: BoxDecoration(
                    color: isToday
                        ? widget.accentColor
                        : widget.accentColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  days[i],
                  style: TextStyle(
                    fontSize: 11,
                    color: isToday
                        ? AppTheme.textPrimary
                        : AppTheme.textTertiary,
                    fontWeight:
                        isToday ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}
