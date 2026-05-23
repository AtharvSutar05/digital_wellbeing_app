import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage_state.dart';
import 'package:wellbeing_app/components/cards/app_info_card.dart';
import 'package:wellbeing_app/models/custom_app_info.dart';
import 'package:wellbeing_app/utils/app_constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<AppUsageBloc, AppUsageState>(
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
                return buildUserGuideMessage();
              }
              return ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                itemCount: customAppInfoList.length,
                itemBuilder: (_, i) {
                  final app = customAppInfoList[i];
                  return AppInfoCard(
                    appInfo: app,
                    totalUsage: app.usage,
                  );
                },
                separatorBuilder: (_, _) {
                  return SizedBox(height: 8);
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
            usageAppsSection(context: context,customAppInfoList: customAppInfoList),
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
        return AppInfoCard(
          appInfo: app,
          totalUsage: app.usage,
        );
      },
      separatorBuilder: (_, _) {
        return SizedBox(height: 8);
      },
    );
  }

  Widget buildUserGuideMessage() {
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
              "No Usage Data Found",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF191C1C),
                fontFamily: "Manrope",
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "To see your app usage, please ensure you have enabled Usage Access for this app.\n\nGo to Settings → Digital Wellbeing (or Special App Access) → Usage Access → Enable for this app.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF404847),
                fontFamily: "Manrope",
                fontWeight: FontWeight.w400,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: const Text(
                "Open Settings",
                style: TextStyle(
                  fontFamily: "Manrope",
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
