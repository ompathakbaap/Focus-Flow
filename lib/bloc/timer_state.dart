part of 'timer_bloc.dart';

enum SessionType { focus, shortBreak, longBreak }

extension SessionTypeExtension on SessionType {
  String get label {
    switch (this) {
      case SessionType.focus:
        return 'Focus';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  int get defaultDuration {
    switch (this) {
      case SessionType.focus:
        return 25 * 60;
      case SessionType.shortBreak:
        return 5 * 60;
      case SessionType.longBreak:
        return 15 * 60;
    }
  }
}

abstract class TimerState extends Equatable {
  final int remaining;
  final SessionType sessionType;
  final int completedPomodoros;

  const TimerState({
    required this.remaining,
    required this.sessionType,
    required this.completedPomodoros,
  });

  @override
  List<Object?> get props => [remaining, sessionType, completedPomodoros];
}

class TimerInitial extends TimerState {
  const TimerInitial({
    required super.remaining,
    required super.sessionType,
    required super.completedPomodoros,
  });
}

class TimerRunning extends TimerState {
  const TimerRunning({
    required super.remaining,
    required super.sessionType,
    required super.completedPomodoros,
  });
}

class TimerPausedState extends TimerState {
  const TimerPausedState({
    required super.remaining,
    required super.sessionType,
    required super.completedPomodoros,
  });
}

class TimerFinished extends TimerState {
  const TimerFinished({
    required super.remaining,
    required super.sessionType,
    required super.completedPomodoros,
  });
}
