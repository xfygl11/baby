import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/activity_records.dart';

class ActivityRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  ActivityRepository(this._db);

  Future<ActivityRecord> insert(ActivityRecordsCompanion entity) async {
    final id = _uuid.v4();
    final companion = entity.copyWith(id: Value(id));
    final insertedId = await _db.into(_db.activityRecords).insert(companion);
    return _db.activityRecords.get(insertedId);
  }

  Future<int> updateById(String id, ActivityRecordsCompanion entity) async {
    return _db.update(_db.activityRecords)
      ..where((t) => t.id.equals(id))
      ..write(entity.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<int> deleteById(String id) async {
    return _db.update(_db.activityRecords)
      ..where((t) => t.id.equals(id))
      ..write(ActivityRecordsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
      ));
  }

  Future<ActivityRecord?> getById(String id) async {
    return (_db.select(_db.activityRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<ActivityRecord>> getAll(String babyId) async {
    return (_db.select(_db.activityRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }

  Future<List<ActivityRecord>> getToday(String babyId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (_db.select(_db.activityRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.startTime.isBiggerOrEqual(today))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }

  Future<List<ActivityRecord>> getByType(String babyId, String activityType) async {
    return (_db.select(_db.activityRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.activityType.equals(activityType))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }

  Future<List<ActivityRecord>> getOngoing(String babyId) async {
    return (_db.select(_db.activityRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.endTime.isNull())
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }
}