import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/temperature_records.dart';

class TemperatureRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  TemperatureRepository(this._db);

  Future<String> addTemperature({
    required String babyId,
    required double temperature,
    required TemperatureSiteEnum site,
    required DateTime recordTime,
    String? note,
  }) async {
    final id = _uuid.v4();
    final isFever = temperature >= 37.5;
    await _db.into(_db.temperatureRecords).insert(
          TemperatureRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            temperature: temperature,
            site: Value(site),
            recordTime: recordTime,
            note: Value(note),
            isFever: Value(isFever),
          ),
        );
    return id;
  }

  Future<List<TemperatureRecord>> getTodayTemperatures(String babyId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return (_db.select(_db.temperatureRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordTime.isBiggerOrEqualValue(startOfDay))
          ..where((t) => t.recordTime.isSmallerOrEqualValue(endOfDay))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
        .get();
  }

  Future<TemperatureRecord?> getLatestTemperature(String babyId) async {
    return (_db.select(_db.temperatureRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<TemperatureRecord>> getTemperaturesByDateRange(
    String babyId,
    DateTime start,
    DateTime end,
  ) async {
    return (_db.select(_db.temperatureRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordTime.isBiggerOrEqualValue(start))
          ..where((t) => t.recordTime.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
        .get();
  }

  Future<TemperatureRecord?> getTemperatureById(String id) async {
    return (_db.select(_db.temperatureRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateTemperature(
      String id, TemperatureRecordsCompanion data) async {
    final Value<bool> isFever = data.temperature.present
        ? Value(data.temperature.value >= 37.5)
        : const Value.absent();
    await (_db.update(_db.temperatureRecords)..where((t) => t.id.equals(id)))
        .write(data.copyWith(
      updatedAt: Value(DateTime.now()),
      isFever: isFever,
    ));
  }

  Future<void> deleteTemperature(String id) async {
    await (_db.update(_db.temperatureRecords)..where((t) => t.id.equals(id)))
        .write(
      TemperatureRecordsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
