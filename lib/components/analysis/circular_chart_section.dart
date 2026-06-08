import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_state.dart';
import 'package:wellbeing_app/models/custom_app_info.dart';
import 'package:wellbeing_app/utils/app_constants.dart';

class CircularChartSection extends StatelessWidget {
  const CircularChartSection({super.key});

  static const _colors = [
    Color(AppConstants.primary),
    Color(0xFF4CAF8D),
    Color(0xFF7B61FF),
    Color(0xFFFF8C42),
    Color(0xFFE05C97),
    Color(0xFFCFD8DC), // Others
  ];

  List<CustomAppInfo> _buildDisplayList(List<CustomAppInfo> appInfoList) {
    final sorted = [...appInfoList]..sort((a, b) => b.usage.compareTo(a.usage));
    final top = sorted.take(5).toList();
    final rest = sorted.skip(5).toList();

    return [
      ...top,
      if (rest.isNotEmpty)
        CustomAppInfo(
          name: 'Others (${rest.length})',
          packageName: '__others__',
          usage: rest.fold(Duration.zero, (sum, a) => sum + a.usage),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUsageBloc, AppUsageState>(
      builder: (context, state) {
        if (state is AppUsageLoading) {
          return const AspectRatio(
            aspectRatio: 1,
            child: Center(
              child: CircularProgressIndicator(
                color: Color(AppConstants.primary),
              ),
            ),
          );
        }

        if (state is AppUsageLoaded) {
          final totalUsage = Duration(milliseconds: state.totalUsage);
          final displayList = _buildDisplayList(state.appInfoList);

          return SfCircularChart(
            margin: EdgeInsets.zero,
            annotations: <CircularChartAnnotation>[
              CircularChartAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Total Usage",
                      style: TextStyle(
                        color: Color(0xFF191C1C),
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 0,
                        letterSpacing: 0,
                      ),
                    ),
                    Text(
                      AppConstants.formatDuration(usage: totalUsage),
                      style: const TextStyle(
                        color: Color(0xFF191C1C),
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        height: 0,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            tooltipBehavior: TooltipBehavior(
              enable: true,
              builder: (dynamic data, _, _, _, _) {
                final app = data as CustomAppInfo;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${app.name} : ${AppConstants.formatDuration(usage: app.usage)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Manrope",
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 0,
                      letterSpacing: 0,
                    ),
                  ),
                );
              },
            ),
            series: <CircularSeries>[
              DoughnutSeries<CustomAppInfo, String>(
                radius: '70%',
                dataSource: displayList,
                xValueMapper: (app, _) => app.name,
                yValueMapper: (app, _) => app.usage.inSeconds,
                pointColorMapper: (app, i) => _colors[i % _colors.length],
                enableTooltip: true,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  connectorLineSettings: ConnectorLineSettings(
                    type: ConnectorType.curve,
                    length: '10%',
                  ),
                  textStyle: TextStyle(
                    fontFamily: "Manrope",
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    height: 0,
                    letterSpacing: 0,
                  ),
                ),
                dataLabelMapper: (app, _) => app.name,
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}