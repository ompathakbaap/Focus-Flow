import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/timer_bloc.dart';
import '../theme/app_theme.dart';
import '../widgets/timer_painter.dart';
import '../widgets/pulse_ring.dart';
import '../widgets/session_type_selector.dart';
import '../widgets/pomodoro_dots.dart';
import 'stats_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Color _accentColor(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return AppTheme.focusAccent;
      case SessionType.shortBreak:
        return AppTheme.shortBreakAccent;
      case SessionType.longBreak:
        return AppTheme.longBreakAccent;
    }
  }

  Color _glowColor(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return AppTheme.focusGlow;
      case SessionType.shortBreak:
        return AppTheme.shortBreakGlow;
      case SessionType.longBreak:
        return AppTheme.longBreakGlow;
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TimerBloc, TimerState>(
      listener: (context, state) {
        if (state is TimerFinished) {
          _showFinishedSnackbar(context, state);
        }
      },
      builder: (context, state) {
        final accent = _accentColor(state.sessionType);
        final glow = _glowColor(state.sessionType);
        final total = state.sessionType.defaultDuration.toDouble();
        final progress = state.remaining / total;
        final isRunning = state is TimerRunning;

        return FadeTransition(
          opacity: _fadeAnim,
          child: Scaffold(
            backgroundColor: AppTheme.background,
            body: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(context, state, accent),
                  const SizedBox(height: 16),
                  _buildSessionSelector(context, state),
                  const Spacer(),
                  _buildTimerFace(context, state, accent, glow, progress, isRunning),
                  const Spacer(),
                  _buildPomodoroDots(state, accent),
                  const SizedBox(height: 24),
                  _buildControls(context, state, accent, isRunning),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, TimerState state, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                  boxShadow: [BoxShadow(color: accent.withOpacity(0.6), blurRadius: 6)],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'FOCUS FLOW',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, anim, __) => const StatsScreen(),
                transitionsBuilder: (_, anim, __, child) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.bar_chart_rounded, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  const Text(
                    'Stats',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSelector(BuildContext context, TimerState state) {
    return SessionTypeSelector(
      selected: state.sessionType,
      onChanged: (type) {
        context.read<TimerBloc>().add(TimerSessionTypeChanged(type));
      },
    );
  }

  Widget _buildTimerFace(BuildContext context, TimerState state, Color accent,
      Color glow, double progress, bool isRunning) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring
          PulseRing(color: accent, size: 280, active: isRunning),
          // Second pulse ring (offset timing)
          Opacity(
            opacity: 0.5,
            child: PulseRing(color: accent, size: 250, active: isRunning),
          ),
          // Timer arc painter
          CustomPaint(
            size: const Size(260, 260),
            painter: TimerPainter(
              progress: progress,
              accentColor: accent,
              glowColor: glow,
              isRunning: isRunning,
            ),
          ),
          // Inner content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: state is TimerFinished ? 20 : 52,
                  fontWeight: FontWeight.w300,
                  color: state is TimerFinished ? accent : AppTheme.textPrimary,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
                child: Text(
                  state is TimerFinished
                      ? 'DONE'
                      : _formatTime(state.remaining),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedOpacity(
                opacity: isRunning ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  state.sessionType.label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPomodoroDots(TimerState state, Color accent) {
    return PomodoroDots(
      completed: state.completedPomodoros,
      accentColor: accent,
    );
  }

  Widget _buildControls(BuildContext context, TimerState state, Color accent,
      bool isRunning) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset
        _ControlButton(
          icon: Icons.refresh_rounded,
          onTap: () => context.read<TimerBloc>().add(TimerReset()),
          color: AppTheme.textTertiary,
          size: 48,
        ),
        const SizedBox(width: 20),
        // Main play/pause
        GestureDetector(
          onTap: () {
            final bloc = context.read<TimerBloc>();
            if (state is TimerInitial) {
              bloc.add(TimerStarted(state.remaining));
            } else if (state is TimerRunning) {
              bloc.add(TimerPaused());
            } else if (state is TimerPausedState) {
              bloc.add(TimerResumed());
            } else if (state is TimerFinished) {
              bloc.add(TimerSessionTypeChanged(state.sessionType));
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(isRunning ? 0.4 : 0.2),
                  blurRadius: isRunning ? 20 : 10,
                  spreadRadius: isRunning ? 2 : 0,
                ),
              ],
            ),
            child: Icon(
              state is TimerRunning
                  ? Icons.pause_rounded
                  : state is TimerFinished
                      ? Icons.replay_rounded
                      : Icons.play_arrow_rounded,
              color: AppTheme.background,
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Skip
        _ControlButton(
          icon: Icons.skip_next_rounded,
          onTap: () {
            final types = SessionType.values;
            final nextIdx =
                (types.indexOf(state.sessionType) + 1) % types.length;
            context
                .read<TimerBloc>()
                .add(TimerSessionTypeChanged(types[nextIdx]));
          },
          color: AppTheme.textTertiary,
          size: 48,
        ),
      ],
    );
  }

  void _showFinishedSnackbar(BuildContext context, TimerFinished state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: _accentColor(state.sessionType), size: 20),
            const SizedBox(width: 10),
            Text(
              '${state.sessionType.label} session complete!',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
