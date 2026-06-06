import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/session_model.dart';
import '../theme/app_theme.dart';
import '../widgets/stats_chart.dart';
import '../bloc/timer_bloc.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  List<int> _buildWeekData(Box<SessionRecord> box) {
    final now = DateTime.now();
    final counts = List<int>.filled(7, 0);

    for (final record in box.values) {
      if (record.sessionType != 'focus') continue;
      final diff = now.difference(record.date).inDays;
      if (diff >= 0 && diff < 7) {
        final dayIndex = (record.date.weekday - 1) % 7;
        counts[dayIndex]++;
      }
    }
    return counts;
  }

  int _totalFocusMinutes(Box<SessionRecord> box) {
    return box.values
        .where((r) => r.sessionType == 'focus' && r.completed)
        .fold(0, (sum, r) => sum + r.durationMinutes);
  }

  int _todaySessions(Box<SessionRecord> box) {
    final now = DateTime.now();
    return box.values
        .where((r) =>
            r.sessionType == 'focus' &&
            r.date.year == now.year &&
            r.date.month == now.month &&
            r.date.day == now.day)
        .length;
  }

  int _currentStreak(Box<SessionRecord> box) {
    if (box.isEmpty) return 0;
    final now = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: i));
      final hasSessions = box.values.any((r) =>
          r.sessionType == 'focus' &&
          r.date.year == day.year &&
          r.date.month == day.month &&
          r.date.day == day.day);
      if (hasSessions) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<SessionRecord>('sessions');
    final weekData = _buildWeekData(box);
    final totalMinutes = _totalFocusMinutes(box);
    final todayCount = _todaySessions(box);
    final streak = _currentStreak(box);
    const accent = AppTheme.focusAccent;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildStatCards(totalMinutes, todayCount, streak),
                    const SizedBox(height: 32),
                    _buildWeekSection(weekData),
                    const SizedBox(height: 32),
                    _buildSessionList(box),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppTheme.textSecondary, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(int totalMinutes, int todayCount, int streak) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'TODAY',
            value: '$todayCount',
            unit: 'sessions',
            accent: AppTheme.focusAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'TOTAL',
            value: hours > 0 ? '${hours}h ${mins}m' : '${mins}m',
            unit: 'focused',
            accent: AppTheme.longBreakAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'STREAK',
            value: '$streak',
            unit: 'days',
            accent: AppTheme.shortBreakAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekSection(List<int> weekData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THIS WEEK',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textTertiary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: SizedBox(
            height: 120,
            child: StatsChart(
              dailySessions: weekData,
              accentColor: AppTheme.focusAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionList(Box<SessionRecord> box) {
    final sessions = box.values.toList().reversed.take(10).toList();

    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'No sessions yet.\nStart your first focus session!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textTertiary,
              height: 1.8,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT SESSIONS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textTertiary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        ...sessions.map((s) => _SessionRow(session: s)).toList(),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textTertiary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final SessionRecord session;

  const _SessionRow({required this.session});

  Color _colorForType(String type) {
    switch (type) {
      case 'focus':
        return AppTheme.focusAccent;
      case 'shortBreak':
        return AppTheme.shortBreakAccent;
      default:
        return AppTheme.longBreakAccent;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'focus':
        return 'Focus';
      case 'shortBreak':
        return 'Short Break';
      default:
        return 'Long Break';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(session.sessionType);
    final hour = session.date.hour.toString().padLeft(2, '0');
    final min = session.date.minute.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _labelForType(session.sessionType),
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            '${session.durationMinutes}m',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$hour:$min',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textTertiary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
