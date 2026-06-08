import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_event.dart';
import 'package:wellbeing_app/blocs/weekly_analysis/weekly_analysis_bloc.dart';
import 'package:wellbeing_app/blocs/weekly_analysis/weekly_analysis_state.dart';
import 'package:wellbeing_app/blocs/weekly_analysis/weekly_usage_event.dart';
import 'package:wellbeing_app/models/weekly_usage_point.dart';
import 'package:wellbeing_app/utils/app_constants.dart';

class WeeklyAnalysisSection extends StatelessWidget {
  const WeeklyAnalysisSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeeklyAnalysisBloc, WeeklyAnalysisState>(
      builder: (context, state) {
        if (state is WeeklyAnalysisLoading) {
          return Container(
            width: double.infinity,
            height: 200,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEEED),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text(
              "weekly analysis loading..",
              style: TextStyle(
                color: Color(0xFF404847),
                fontFamily: "Manrope",
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          );
        }
        if (state is WeeklyAnalysisLoaded) {
          final weeklyUsage = state.weeklyUsage;
          final selectedDate = state.selectedDate;
          if (weeklyUsage.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Text(
                "No Weekly Usage!",
                style: TextStyle(
                  color: Color(0xFF404847),
                  fontFamily: "Manrope",
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            );
          }

          return Container(
            height: 220,
            margin: EdgeInsets.zero,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
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
                    context.read<WeeklyAnalysisBloc>().add(
                      UpdateSelectedDate(selectedDate: tappedDate),
                    );
                    context.read<AppUsageBloc>().add(
                      LoadAppsUsage(date: tappedDate),
                    );
                  },
                  dataSource: weeklyUsage,
                  xValueMapper: (data, _) => data.dayLabel,
                  yValueMapper: (data, _) =>
                  data.usageMillis / (1000 * 60 * 60),
                  pointColorMapper: (data, _) {
                    if (data.date == selectedDate) {
                      return const Color(AppConstants.primary);
                    }
                    return const Color(AppConstants.tertiary);
                  },
                ),
              ],
            ),
          );
        }
        return SizedBox();
      },
    );
  }
}
