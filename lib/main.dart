import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage_event.dart';
import 'package:wellbeing_app/screens/home_page.dart';
import 'package:wellbeing_app/utils/app_constants.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppUsageBloc()..add(LoadAppsUsage())),
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
      home: const HomePage(),
    );
  }
}
