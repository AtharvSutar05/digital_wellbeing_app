import 'package:hive/hive.dart';
import 'package:installed_apps/app_info.dart';
import 'package:wellbeing_app/models/app_meta_data_model.dart';

class AppMetaDataCacheService {
  static final AppMetaDataCacheService _instance =
      AppMetaDataCacheService._internal();

  factory AppMetaDataCacheService() => _instance;

  AppMetaDataCacheService._internal();

  static const _boxName = 'app_metadata';

  late final Box<AppMetaDataModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<AppMetaDataModel>(_boxName);
  }

  Future<Map<String, AppMetaDataModel>?> loadAll() async {
    if (_box.isEmpty) return null;
    return {for (final e in _box.values) e.packageName: e};
  }

  // load apps form installed apps and store in hive
  Future<void> saveAll(List<AppInfo> apps) async {
    final now = DateTime.now();

    final entries = {
      for (final app in apps)
        app.packageName: AppMetaDataModel(
          packageName: app.packageName,
          name: app.name,
          categoryIndex: app.category.value,
          isLaunchable: app.isLaunchableApp,
          lastSynced: now,
        ),
    };
    await _box.putAll(entries);
  }

  Future<void> updateCategory({
    required String packageName,
    required int categoryIndex,
  }) async {
    final existing = _box.get(packageName);
    if (existing != null) {
      await _box.put(
        packageName,
        existing.copyWith(
          packageName: existing.packageName,
          name: existing.name,
          lastSynced: DateTime.now(),
          categoryIndex: categoryIndex,
        ),
      );
    }
  }

  Future<void> updateDailyLimit({
    required String packageName,
    required int? dailyLimit,
  }) async {
    final existing = _box.get(packageName);
    if (existing != null) {
      _box.put(
        packageName,
        existing.copyWith(
          packageName: existing.packageName,
          name: existing.name,
          lastSynced: DateTime.now(),
          dailyLimit: dailyLimit,
          clearDailyLimit: dailyLimit == null,
        ),
      );
    }
  }

  Future<void> updateTracking({
    required String packageName,
    required bool isTracking,
  }) async {
    final existing = _box.get(packageName);
    if (existing != null) {
      _box.put(
        packageName,
        existing.copyWith(
          packageName: existing.packageName,
          name: existing.name,
          lastSynced: DateTime.now(),
          isTracked: isTracking,
        ),
      );
    }
  }
}
