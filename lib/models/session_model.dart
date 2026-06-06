import 'package:hive/hive.dart';

part 'session_model.g.dart';

@HiveType(typeId: 0)
class SessionRecord extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int durationMinutes;

  @HiveField(2)
  final String sessionType; // 'focus' | 'short_break' | 'long_break'

  @HiveField(3)
  final bool completed;

  SessionRecord({
    required this.date,
    required this.durationMinutes,
    required this.sessionType,
    required this.completed,
  });
}
