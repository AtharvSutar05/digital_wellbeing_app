import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wellbeing_app/blocs/analytics/analytics_bloc.dart';
import 'package:wellbeing_app/blocs/analytics/analytics_event.dart';
import 'package:wellbeing_app/blocs/analytics/analytics_state.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_event.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_state.dart';
import 'package:wellbeing_app/components/cards/app_info_card.dart';
import 'package:wellbeing_app/models/custom_app_info.dart';
import 'package:wellbeing_app/services/usage_access_service.dart';
import 'package:wellbeing_app/utils/app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final UsageAccessService _usageAccessService;
  late final AppLifecycleListener _lifecycleListener;
  bool? _usageAccessGranted;

  @override
  void initState() {
    super.initState();
    _usageAccessService = UsageAccessService();
    _checkUsageAccess();
    _lifecycleListener = AppLifecycleListener(
      onResume: () => _checkUsageAccess(),
    );
  }

  Future<void> _checkUsageAccess() async {
    final granted = await _usageAccessService.isUsageAccessGranted();

    if (!mounted) return;

    if (_usageAccessGranted != granted) {
      setState(() {
        _usageAccessGranted = granted;
      });
    }

    final state = context.read<AppUsageBloc>().state;
    if (granted && state is! AppUsageLoaded) {
      context.read<AppUsageBloc>().add(LoadAppsUsage(date: DateTime.now(), totalUsage: 0));
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return SafeArea(
      child: Scaffold(
        body: _usageAccessGranted == null
            ? const Center(child: CircularProgressIndicator())
            : !_usageAccessGranted!
            ? _buildUsageAccessRequired()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<AppUsageBloc, AppUsageState>(builder: (context, state) {
                      if(state is AppUsageLoaded) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            const Text(
                              "Total Usage:",
                              style: TextStyle(
                                  fontFamily: "Manrope",
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0
                              ),
                            ),
                            Text(
                              AppConstants.formatDuration(
                                usage: Duration(
                                  milliseconds: state.totalUsage,
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: "Manrope",
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                            ),
                          ],),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    BlocBuilder<AnalyticsBloc, AnalyticsState>(
                      builder: (context, state) {
                        if (state is AnalyticsLoaded) {
                          if (state.weeklyUsage.isEmpty) {
                            return SizedBox(
                              height: 160,
                              child: Text("No Weekly Usage"),
                            );
                          }
                          final maxUsage = state.weeklyUsage
                              .map((e) => e.usageMillis)
                              .reduce(max);
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 24.0,
                              right: 24.0,
                              top: 16.0,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: state.weeklyUsage.map((point) {
                                return GestureDetector(
                                  onTap: () {
                                    context.read<AppUsageBloc>().add(
                                      LoadAppsUsage(date: point.date, totalUsage: point.usageMillis),
                                    );
                                    context.read<AnalyticsBloc>().add(
                                      UpdateAnalyticsDateAndUsage(
                                        date: point.date,
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    height: 160,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: maxUsage == 0
                                              ? 4
                                              : (point.usageMillis /
                                                        maxUsage) *
                                                    120,
                                          decoration: BoxDecoration(
                                            color:
                                                point.date ==
                                                    state.selectedDate
                                                ? Colors.blue
                                                : Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          point.dayLabel,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: "Manrope",
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                    BlocBuilder<AppUsageBloc, AppUsageState>(
                      builder: (context, state) {
                        if (state is AppUsageError) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Center(
                              child: Text(
                                state.message,
                                style: const TextStyle(
                                  color: Color(0xFF404847),
                                  fontFamily: "Manrope",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }

                        if (state is AppUsageLoaded) {
                          final List<CustomAppInfo> customAppInfoList =
                              state.appInfoList;

                          final Duration totalUsage = customAppInfoList.fold(
                            Duration.zero,
                            (sum, app) => sum + app.usage,
                          );
                          if (totalUsage.inSeconds == 0) {
                            return Center(
                              child: const Text(
                                "No Usage Today",
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: Color(0xFF191C1C),
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 24.0,
                            ),
                            itemCount: customAppInfoList.length,
                            itemBuilder: (_, i) {
                              final app = customAppInfoList[i];
                              return AppInfoCard(
                                appInfo: app,
                                totalUsage: app.usage,
                              );
                            },
                            separatorBuilder: (_, _) {
                              return const SizedBox(height: 8);
                            },
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(AppConstants.primary),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget portraitLayout({
    required BuildContext context,
    required Duration totalUsage,
    required List<CustomAppInfo> customAppInfoList,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            usageAppsSection(
              context: context,
              customAppInfoList: customAppInfoList,
            ),
          ],
        ),
      ),
    );
  }

  Widget landscapeLayout({
    required BuildContext context,
    required Duration totalUsage,
    required List<CustomAppInfo> customAppInfoList,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: usageAppsSection(
              context: context,
              customAppInfoList: customAppInfoList,
              isScrollable: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget usageAppsSection({
    required BuildContext context,
    required List<CustomAppInfo> customAppInfoList,
    bool isScrollable = false,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      itemCount: customAppInfoList.length,
      itemBuilder: (_, i) {
        final app = customAppInfoList[i];
        return AppInfoCard(appInfo: app, totalUsage: app.usage);
      },
      separatorBuilder: (_, _) {
        return SizedBox(height: 8);
      },
    );
  }

  Widget _buildUsageAccessRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 64,
              color: Color(AppConstants.primary).withAlpha(80),
            ),
            const SizedBox(height: 16),
            const Text(
              'Usage access required',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF191C1C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Grant usage access so this app can track your daily screen time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: Color(0xFF404847),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await _usageAccessService.openUsageAccessSettings();
              },
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: const Text(
                'Grant access',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppConstants.primary),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
