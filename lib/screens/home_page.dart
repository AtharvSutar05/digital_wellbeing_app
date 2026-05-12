import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wellbeing_app/blocs/app_usage_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage_state.dart';
import 'package:wellbeing_app/components/cards/app_info_card.dart';
import 'package:wellbeing_app/models/category_group.dart';
import 'package:wellbeing_app/utils/app_category_theme.dart';
import 'package:wellbeing_app/utils/app_constants.dart';
import 'package:wellbeing_app/utils/enums.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<AppUsageBloc, AppUsageState>(
          builder: (context, state) {
            if (state is AppUsageLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(AppConstants.primary),
                ),
              );
            }
            if (state is AppUsageError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(
                    color: Color(0xFF404847),
                    fontFamily: "Manrope",
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              );
            }
            if (state is AppUsageLoaded) {
              final List<CategoryGroup> categoryGroupList =
                  state.categoryGroupList;

              final Duration totalUsage = categoryGroupList.fold(
                Duration.zero,
                (sum, group) => sum + group.totalUsage,
              );

              return isLandscape
                  ? landscapeLayout(
                      totalUsage: totalUsage,
                      categoryGroupList: categoryGroupList,
                    )
                  : portraitLayout(
                      totalUsage: totalUsage,
                      categoryGroupList: categoryGroupList,
                    );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget portraitLayout({
    required Duration totalUsage,
    required List<CategoryGroup> categoryGroupList,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            circularChartSection(
              totalUsage: totalUsage,
              categoryGroupList: categoryGroupList,
            ),
            const SizedBox(height: 16),
            usageAppsSection(categoryGroupList: categoryGroupList),
          ],
        ),
      ),
    );
  }

  Widget landscapeLayout({
    required Duration totalUsage,
    required List<CategoryGroup> categoryGroupList,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          circularChartSection(
            totalUsage: totalUsage,
            categoryGroupList: categoryGroupList,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: usageAppsSection(
              categoryGroupList: categoryGroupList,
              isScrollable: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget circularChartSection({
    required Duration totalUsage,
    required List<CategoryGroup> categoryGroupList,
  }) {
    return AspectRatio(
      aspectRatio: 1,
      child: SfCircularChart(
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
            final group = data as CategoryGroup;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${group.category.displayName} : ${AppConstants.formatDuration(usage: group.totalUsage)}",
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
        legend: Legend(
          isVisible: true,
          textStyle: const TextStyle(
            color: Color(0xFF191C1C),
            fontFamily: "Manrope",
            fontWeight: FontWeight.w600,
            fontSize: 12,
            height: 0,
            letterSpacing: 0,
          ),
          iconHeight: 16,
          iconWidth: 16,
          overflowMode: LegendItemOverflowMode.wrap,
          position: LegendPosition.bottom,
        ),
        series: <CircularSeries>[
          DoughnutSeries<CategoryGroup, String>(
            radius: '80%',
            dataSource: categoryGroupList,
            xValueMapper: (CategoryGroup data, _) =>
                data.category.displayName,
            yValueMapper: (CategoryGroup data, _) =>
                data.totalUsage.inSeconds,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: const TextStyle(
                fontFamily: "Manrope",
                fontWeight: FontWeight.w600,
                fontSize: 10,
                height: 0,
                letterSpacing: 0,
              ),
            ),
            dataLabelMapper: (CategoryGroup data, _) {
              final percent =
                  (data.totalUsage.inSeconds / totalUsage.inSeconds) * 100;
              return '${percent.toStringAsFixed(0)}%';
            },
            enableTooltip: true,
            pointColorMapper: (CategoryGroup data, _) =>
                AppCategoryTheme.color(data.category),
          ),
        ],
      ),
    );
  }

  Widget usageAppsSection({
    required List<CategoryGroup> categoryGroupList,
    bool isScrollable = false,
  }) {
    return ListView.separated(
      shrinkWrap: !isScrollable,
      physics: isScrollable
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: categoryGroupList.length,
      separatorBuilder: (_, index) => const SizedBox(height: 16),
      itemBuilder: (_, index) {
        final category = categoryGroupList[index];
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFEDEEED),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(AppConstants.primary).withAlpha(24),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          AppCategoryTheme.icon(category.category),
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.category.displayName,
                              style: const TextStyle(
                                color: Color(0xFF191C1C),
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                                height: 0,
                                letterSpacing: 0,
                              ),
                            ),
                            Text(
                              AppConstants.formatDuration(
                                usage: category.totalUsage,
                                showSeconds: false,
                              ),
                              style: const TextStyle(
                                color: Color(0xFF191C1C),
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 0,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {},
                      child: const Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: Color(0xFF191C1C),
                      ),
                    ),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                itemCount: category.apps.length,
                itemBuilder: (_, i) {
                  final app = category.apps[i];
                  return AppInfoCard(
                    appInfo: app,
                    totalUsage: category.totalUsage,
                  );
                },
                separatorBuilder: (_, _) {
                  return SizedBox(height: 8);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
