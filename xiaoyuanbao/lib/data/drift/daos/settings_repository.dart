import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_settings.dart';

class SettingsRepository {
  final AppDatabase _db;

  SettingsRepository(this._db);

  Future<String?> getSetting(String key) async {
    final result = await (_db.select(_db.appSettings)
          ..where((t) => t.id.equals(key)))
        .getSingleOrNull();
    return result?.value;
  }

  Future<void> setSetting(String key, String value) async {
    final existing = await (_db.select(_db.appSettings)
          ..where((t) => t.id.equals(key)))
        .getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.appSettings)..where((t) => t.id.equals(key))).write(
            AppSettingsCompanion(
              value: Value(value),
              updatedAt: Value(DateTime.now()),
            ),
          );
    } else {
      await _db.into(_db.appSettings).insert(
            AppSettingsCompanion.insert(
              id: key,
              value: Value(value),
              type: const Value('string'),
            ),
          );
    }
  }

  Future<bool?> getBoolSetting(String key) async {
    final result = await (_db.select(_db.appSettings)
          ..where((t) => t.id.equals(key))
          ..where((t) => t.type.equals('bool')))
        .getSingleOrNull();
    if (result?.value == null) return null;
    return result!.value == 'true';
  }

  Future<void> setBoolSetting(String key, bool value) async {
    final existing = await (_db.select(_db.appSettings)
          ..where((t) => t.id.equals(key)))
        .getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.appSettings)..where((t) => t.id.equals(key))).write(
            AppSettingsCompanion(
              value: Value(value.toString()),
              type: const Value('bool'),
              updatedAt: Value(DateTime.now()),
            ),
          );
    } else {
      await _db.into(_db.appSettings).insert(
            AppSettingsCompanion.insert(
              id: key,
              value: Value(value.toString()),
              type: const Value('bool'),
            ),
          );
    }
  }

  Future<int?> getIntSetting(String key) async {
    final result = await (_db.select(_db.appSettings)
          ..where((t) => t.id.equals(key))
          ..where((t) => t.type.equals('int')))
        .getSingleOrNull();
    if (result?.value == null) return null;
    return int.tryParse(result!.value!);
  }

  Future<void> setIntSetting(String key, int value) async {
    final existing = await (_db.select(_db.appSettings)
          ..where((t) => t.id.equals(key)))
        .getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.appSettings)..where((t) => t.id.equals(key))).write(
            AppSettingsCompanion(
              value: Value(value.toString()),
              type: const Value('int'),
              updatedAt: Value(DateTime.now()),
            ),
          );
    } else {
      await _db.into(_db.appSettings).insert(
            AppSettingsCompanion.insert(
              id: key,
              value: Value(value.toString()),
              type: const Value('int'),
            ),
          );
    }
  }

  Future<double?> getDoubleSetting(String key) async {
    final result = await (_db.select(_db.appSettings)
          ..where((t) => t.id.equals(key))
          ..where((t) => t.type.equals('double')))
        .getSingleOrNull();
    if (result?.value == null) return null;
    return double.tryParse(result!.value!);
  }

  Future<void> setDoubleSetting(String key, double value) async {
    final existing = await (_db.select(_db.appSettings)
          ..where((t) => t.id.equals(key)))
        .getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.appSettings)..where((t) => t.id.equals(key))).write(
            AppSettingsCompanion(
              value: Value(value.toString()),
              type: const Value('double'),
              updatedAt: Value(DateTime.now()),
            ),
          );
    } else {
      await _db.into(_db.appSettings).insert(
            AppSettingsCompanion.insert(
              id: key,
              value: Value(value.toString()),
              type: const Value('double'),
            ),
          );
    }
  }
}
