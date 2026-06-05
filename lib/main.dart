import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_event.dart';
import 'package:wellbeing_app/blocs/weekly_analysis/weekly_analysis_bloc.dart';
import 'package:wellbeing_app/blocs/weekly_analysis/weekly_usage_event.dart';
import 'package:wellbeing_app/screens/home_page.dart';
import 'package:wellbeing_app/services/app_meta_data_cache_service.dart';
import 'package:wellbeing_app/services/daily_usage_service.dart';
import 'package:wellbeing_app/services/pending_usage_sync_service.dart';
import 'package:wellbeing_app/utils/app_constants.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:wellbeing_app/utils/extensions.dart';
import 'models/app_meta_data_model.dart';
import 'models/app_usage_model.dart';
import 'models/daily_usage_model.dart';

void main() async {
  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );
  await Hive.initFlutter();

  // adapters
  Hive.registerAdapter(AppMetaDataModelAdapter());

  Hive.registerAdapter(DailyUsageModelAdapter());

  Hive.registerAdapter(AppUsageModelAdapter());

  // services
  final appMetaDataCacheService = AppMetaDataCacheService();

  await appMetaDataCacheService.init();

  final dailyUsageService = DailyUsageService();

  await dailyUsageService.init();

  // import pending worker data
  await PendingUsageSyncService().syncPendingUsage();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AppUsageBloc()
                ..add(LoadAppsUsage(date: DateTime.now().toDateOnly())),
        ),
        BlocProvider(
          create: (_) => WeeklyAnalysisBloc()..add(LoadWeeklyAnalysis()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppConstants.themeData,
      builder: (context, child) {
        return Container(color: Colors.white, child: child);
      },
      home: const HomePage(),
    );
  }
}
