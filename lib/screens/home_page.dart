import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:wellbeing_app/blocs/app_usage_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage_state.dart';
import 'package:wellbeing_app/components/cards/app_info_card.dart';
import 'package:wellbeing_app/models/catgory_group.dart';
import 'package:wellbeing_app/utils/app_constants.dart';
import 'package:wellbeing_app/utils/enums.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: BlocBuilder<AppUsageBloc, AppUsageState>(
              builder: (context, state) {
                if (state is AppUsageLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AppUsageError) {
                  return Center(child: Text(state.message));
                }
                if (state is AppUsageLoaded) {
                  final List<CategoryGroup> categoryGroupList =
                      state.categoryGroupList;

                  // Total usage across all categories
                  final Duration totalUsage = categoryGroupList.fold(
                    Duration.zero,
                    (sum, group) => sum + group.totalUsage,
                  );

                  final double percent = AppConstants.findPercentage(
                    240,
                    totalUsage.inMinutes,
                  ).clamp(0.0, 1.0); // ✓ safer than inline ternary

                  return Column(
                    children: [
                      CircularPercentIndicator(
                        radius: 110.0,
                        lineWidth: 12,
                        percent: percent,
                        circularStrokeCap: CircularStrokeCap.round,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Today",
                              style: TextStyle(
                                color: Color(0xFF404847),
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              AppConstants.formatDuration(totalUsage),
                              style: const TextStyle(
                                color: Color(0xFF191C1C),
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.w300,
                                fontSize: 48,
                                letterSpacing: -0.96,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 14,
                                  color: Color(0xFF32645E),
                                ),
                                const Text(
                                  "12% less",
                                  style: TextStyle(
                                    color: Color(0xFF32645E),
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    letterSpacing: 0.28,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              "than yesterday",
                              style: TextStyle(
                                color: Color(0xFF32645E),
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: 0.28,
                              ),
                            ),
                          ],
                        ),
                        progressColor: Color(AppConstants.primary),
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryGroupList.length,
                        separatorBuilder: (_, index) => const SizedBox(
                          height: 16,
                        ), // ✓ fixed duplicate param
                        itemBuilder: (_, index) {
                          final category = categoryGroupList[index];
                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDEEED),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.category.displayName,
                                        style: TextStyle(
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
                                          category.totalUsage,
                                        ),
                                        style: TextStyle(
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
                                ),
                                ListView.separated(
                                  shrinkWrap:
                                      true, // ✓ was false — must be true inside Column
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      category.apps.length, // ✓ was missing
                                  itemBuilder: (_, i) {
                                    final app = category.apps[i];
                                    return AppInfoCard(
                                      appInfo: app,
                                      totalUsage: totalUsage,
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
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
