import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_event.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_state.dart';
import 'package:wellbeing_app/components/cards/app_info_card.dart';
import 'package:wellbeing_app/models/custom_app_info.dart';
import 'package:wellbeing_app/models/weekly_usage_point.dart';
import 'package:wellbeing_app/services/usage_access_service.dart';
import 'package:wellbeing_app/utils/app_constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
      setState(() => _usageAccessGranted = granted);
    }
    final state = context.read<AppUsageBloc>().state;
    if (granted && state is! AppUsageLoaded) {
      context.read<AppUsageBloc>().add(
        LoadAppsUsage(date: DateTime.now(), totalUsage: 0),
      );
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _usageAccessGranted == null
            ? const Center(child: CircularProgressIndicator())
            : !_usageAccessGranted!
            ? _buildUsageAccessRequired()
            : OrientationBuilder(
                builder: (context, orientation) {
                  return orientation == Orientation.portrait
                      ? _buildPortraitLayout()
                      : _buildLandscapeLayout();
                },
              ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalUsageHeader(),
          _buildWeeklyChart(height: 200),
          _buildAppListSection(),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTotalUsageHeader(),
                _buildWeeklyChart(height: 180),
              ],
            ),
          ),
        ),
        Expanded(child: _buildAppListSection()),
      ],
    );
  }

  Widget _buildTotalUsageHeader() {
    return BlocBuilder<AppUsageBloc, AppUsageState>(
      builder: (context, state) {
        if (state is AppUsageLoaded) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 16.0,
              bottom: 8.0,
            ),
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
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  AppConstants.formatDuration(
                    usage: Duration(milliseconds: state.totalUsage),
                  ),
                  style: const TextStyle(
                    fontFamily: "Manrope",
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildWeeklyChart({required double height}) {
    return BlocSelector<
      AppUsageBloc,
      AppUsageState,
      ({List<WeeklyUsagePoint> list, DateTime? selectedDate})
    >(
      selector: (state) {
        if (state is AppUsageLoaded) {
          return (list: state.weeklyUsage, selectedDate: state.selectedDate);
        }
        return (list: const [], selectedDate: null);
      },
      builder: (context, selectedData) {
        final weeklyUsage = selectedData.list;
        final selectedDate = selectedData.selectedDate;

        if (weeklyUsage.isEmpty) {
          return SizedBox(
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return SizedBox(
          height: height,
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              interval: 2,
              labelFormat: '{value}h',
              axisLine: const AxisLine(width: 0),
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              format: 'point.x : point.y h',
            ),
            series: <CartesianSeries>[
              ColumnSeries<WeeklyUsagePoint, String>(
                onPointTap: (ChartPointDetails details) {
                  final tappedDate = weeklyUsage[details.pointIndex!].date;
                  final totalUsage =
                      weeklyUsage[details.pointIndex!].usageMillis;
                  context.read<AppUsageBloc>().add(
                    LoadAppsUsage(date: tappedDate, totalUsage: totalUsage),
                  );
                },
                dataSource: weeklyUsage,
                xValueMapper: (data, _) => data.dayLabel,
                yValueMapper: (data, _) => data.usageMillis / (1000 * 60 * 60),
                pointColorMapper: (data, _) {
                  if (selectedDate != null &&
                      data.date.year == selectedDate.year &&
                      data.date.month == selectedDate.month &&
                      data.date.day == selectedDate.day) {
                    return const Color(AppConstants.primary);
                  }
                  return const Color(AppConstants.tertiary);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppListSection() {
    return BlocBuilder<AppUsageBloc, AppUsageState>(
      builder: (context, state) {
        if (state is AppUsageError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
          final List<CustomAppInfo> customAppInfoList = state.appInfoList;
          final Duration totalUsage = customAppInfoList.fold(
            Duration.zero,
            (sum, app) => sum + app.usage,
          );

          if (totalUsage.inSeconds == 0) {
            return const Center(
              child: Text(
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
            physics: _isLandscape()
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 24.0,
            ),
            itemCount: customAppInfoList.length,
            itemBuilder: (_, i) {
              final app = customAppInfoList[i];
              return AppInfoCard(appInfo: app, totalUsage: app.usage);
            },
            separatorBuilder: (_, _) => const SizedBox(height: 8),
          );
        }

        return const Center(
          child: CircularProgressIndicator(color: Color(AppConstants.primary)),
        );
      },
    );
  }

  bool _isLandscape() =>
      MediaQuery.of(context).orientation == Orientation.landscape;

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
