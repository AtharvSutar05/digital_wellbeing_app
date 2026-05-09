import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class AppInfoService {
  Future<List<AppInfo>> getInstalledApps() async {
    try {
      List<AppInfo> apps = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        excludeNonLaunchableApps: true,
        withIcon: false,
        // packageNamePrefix: "com.example",
        // platformType: PlatformType.flutter,
      );
      return apps;
    } catch(e) {
      rethrow;
    }
  }
}