import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import '../models/session_model.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  Timer? _ticker;
  late Box<SessionRecord> _sessionBox;

  TimerBloc(Box<SessionRecord> sessionBox)
      : _sessionBox = sessionBox,
        super(TimerInitial(
          remaining: SessionType.focus.defaultDuration,
          sessionType: SessionType.focus,
          completedPomodoros: 0,
        )) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<TimerTicked>(_onTicked);
    on<TimerSessionTypeChanged>(_onSessionTypeChanged);
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    _ticker?.cancel();
    emit(TimerRunning(
      remaining: event.duration,
      sessionType: state.sessionType,
      completedPomodoros: state.completedPomodoros,
    ));
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TimerTicked(state.remaining - 1));
    });
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    _ticker?.cancel();
    HapticFeedback.lightImpact();
    emit(TimerPausedState(
      remaining: state.remaining,
      sessionType: state.sessionType,
      completedPomodoros: state.completedPomodoros,
    ));
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    HapticFeedback.lightImpact();
    emit(TimerRunning(
      remaining: state.remaining,
      sessionType: state.sessionType,
      completedPomodoros: state.completedPomodoros,
    ));
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TimerTicked(state.remaining - 1));
    });
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _ticker?.cancel();
    HapticFeedback.mediumImpact();
    emit(TimerInitial(
      remaining: state.sessionType.defaultDuration,
      sessionType: state.sessionType,
      completedPomodoros: state.completedPomodoros,
    ));
  }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) async {
    if (event.remaining <= 0) {
      _ticker?.cancel();
      HapticFeedback.heavyImpact();

      // Save session record
      final record = SessionRecord(
        date: DateTime.now(),
        durationMinutes: state.sessionType.defaultDuration ~/ 60,
        sessionType: state.sessionType.name,
        completed: true,
      );
      await _sessionBox.add(record);

      final newPomodoros = state.sessionType == SessionType.focus
          ? state.completedPomodoros + 1
          : state.completedPomodoros;

      emit(TimerFinished(
        remaining: 0,
        sessionType: state.sessionType,
        completedPomodoros: newPomodoros,
      ));
    } else {
      emit(TimerRunning(
        remaining: event.remaining,
        sessionType: state.sessionType,
        completedPomodoros: state.completedPomodoros,
      ));
    }
  }

  void _onSessionTypeChanged(
      TimerSessionTypeChanged event, Emitter<TimerState> emit) {
    _ticker?.cancel();
    HapticFeedback.selectionClick();
    emit(TimerInitial(
      remaining: event.sessionType.defaultDuration,
      sessionType: event.sessionType,
      completedPomodoros: state.completedPomodoros,
    ));
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
