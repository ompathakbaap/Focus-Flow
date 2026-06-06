part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();
  @override
  List<Object?> get props => [];
}

class TimerStarted extends TimerEvent {
  final int duration;
  const TimerStarted(this.duration);
  @override
  List<Object?> get props => [duration];
}

class TimerPaused extends TimerEvent {}

class TimerResumed extends TimerEvent {}

class TimerReset extends TimerEvent {}

class TimerTicked extends TimerEvent {
  final int remaining;
  const TimerTicked(this.remaining);
  @override
  List<Object?> get props => [remaining];
}

class TimerSessionTypeChanged extends TimerEvent {
  final SessionType sessionType;
  const TimerSessionTypeChanged(this.sessionType);
  @override
  List<Object?> get props => [sessionType];
}
