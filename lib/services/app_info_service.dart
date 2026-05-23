import 'dart:typed_data';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class AppInfoService {
  static final AppInfoService _instance = AppInfoService._internal();

  factory AppInfoService() => _instance;

  AppInfoService._internal();
  final Map<String, Future<Uint8List?>> _iconCache = {};

  Future<List<AppInfo>> getInstalledApps() async {
    List<AppInfo> apps = await InstalledApps.getInstalledApps(
      excludeSystemApps: false,
      excludeNonLaunchableApps: true,
      withIcon: false,
      // packageNamePrefix: "com.example",
      // platformType: PlatformType.flutter,
    );
    return apps;
  }

  Future<List<AppInfo>> getAppInfoList(List<String> packageNames) async {
    List<AppInfo> appInfoList = [];
    for(final packageName in packageNames) {
      final appInfo = await InstalledApps.getAppInfo(packageName);
      if(appInfo != null) appInfoList.add(appInfo);
    }
    return appInfoList;
  }

  Future<Uint8List?> getAppIcon(String packageName) {
    return _iconCache.putIfAbsent(packageName, () async {
      final appInfo = await InstalledApps.getAppInfo(packageName);

      return appInfo?.icon;
    });
  }
}
