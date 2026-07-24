import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/growth_records.dart';

class GrowthRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  GrowthRepository(this._db);

  Future<String> addGrowth({
    required String babyId,
    double? weight,
    double? height,
    double? headCircumference,
    required DateTime recordDate,
    String? note,
    String? measurementPlace,
  }) async {
    final id = _uuid.v4();
    double? bmi;
    if (weight != null && height != null && height > 0) {
      bmi = weight / ((height / 100) * (height / 100));
    }
    await _db.into(_db.growthRecords).insert(
          GrowthRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            weight: Value(weight),
            height: Value(height),
            headCircumference: Value(headCircumference),
            bmi: Value(bmi),
            recordDate: recordDate,
            note: Value(note),
            measurementPlace: Value(measurementPlace),
          ),
        );
    return id;
  }

  Future<List<GrowthRecord>> getGrowthRecords(String babyId) async {
    return (_db.select(_db.growthRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .get();
  }

  Future<GrowthRecord?> getLatestGrowth(String babyId) async {
    return (_db.select(_db.growthRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<GrowthRecord?> getGrowthById(String id) async {
    return (_db.select(_db.growthRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateGrowth(String id, GrowthRecordsCompanion data) async {
    double? bmi;
    final weight = data.weight.present ? data.weight.value : null;
    final height = data.height.present ? data.height.value : null;
    if (weight != null && height != null && height > 0) {
      bmi = weight / ((height / 100) * (height / 100));
    }
    await (_db.update(_db.growthRecords)..where((t) => t.id.equals(id)))
        .write(data.copyWith(
      bmi: Value(bmi),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteGrowth(String id) async {
    await (_db.update(_db.growthRecords)..where((t) => t.id.equals(id))).write(
          GrowthRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<GrowthRecord>> getGrowthByDateRange(
    String babyId,
    DateTime start,
    DateTime end,
  ) async {
    return (_db.select(_db.growthRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .get();
  }
}
