import 'package:hive/hive.dart';
import 'package:installed_apps/app_category.dart';
import 'package:installed_apps/app_info.dart';
import 'package:wellbeing_app/models/app_meta_data_model.dart';

class AppMetaDataCacheService {
  static const _boxName = 'app_metadata';
  static const _staleDays = 1; // re-sync after 1 day

  Future<Box<AppMetaDataModel>> _openBox() =>
      Hive.openBox<AppMetaDataModel>(_boxName);

  Future<Map<String, AppMetaDataModel>?> loadAll() async {
    final box = await _openBox();
    if (box.isEmpty) return null;

    // Check if any entry is stale
    final anyStale = box.values.any((e) =>
    DateTime.now().difference(e.lastSynced).inDays >= _staleDays,
    );
    if (anyStale) return null;

    return {for (final e in box.values) e.packageName: e};
  }

  Future<void> saveAll(List<AppInfo> apps) async {
    final box = await _openBox();
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
    await box.putAll(entries); // single write, fast
  }

  // Call when user customizes a category
  Future<void> updateCustomCategory(
      String packageName,
      AppCategory category,
      ) async {
    final box = await _openBox();
    final existing = box.get(packageName);
    if (existing != null) {
      await box.put(
        packageName,
        AppMetaDataModel(
          packageName: existing.packageName,
          name: existing.name,
          categoryIndex: existing.categoryIndex,
          customCategoryIndex: category.index,
          isLaunchable: existing.isLaunchable,
          lastSynced: existing.lastSynced,
        ),
      );
    }
  }
}