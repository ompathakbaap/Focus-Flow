import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'bloc/timer_bloc.dart';
import 'models/session_model.dart';
import 'screens/timer_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(SessionRecordAdapter());
  final sessionBox = await Hive.openBox<SessionRecord>('sessions');

  runApp(FocusFlowApp(sessionBox: sessionBox));
}

class FocusFlowApp extends StatelessWidget {
  final Box<SessionRecord> sessionBox;

  const FocusFlowApp({super.key, required this.sessionBox});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerBloc(sessionBox),
      child: MaterialApp(
        title: 'Focus Flow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const TimerScreen(),
      ),
    );
  }
}
