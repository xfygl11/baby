import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/time_capsule_records.dart';

class TimeCapsuleRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  TimeCapsuleRepository(this._db);

  Future<TimeCapsuleRecord> insert(TimeCapsuleRecordsCompanion entity) async {
    final id = _uuid.v4();
    final companion = entity.copyWith(id: Value(id));
    await _db.into(_db.timeCapsuleRecords).insert(companion);
    return (await getById(id))!;
  }

  Future<int> updateById(String id, TimeCapsuleRecordsCompanion entity) async {
    return (_db.update(_db.timeCapsuleRecords)
          ..where((t) => t.id.equals(id)))
        .write(entity.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<int> deleteById(String id) async {
    return (_db.update(_db.timeCapsuleRecords)
          ..where((t) => t.id.equals(id)))
        .write(TimeCapsuleRecordsCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(DateTime.now()),
        ));
  }

  Future<TimeCapsuleRecord?> getById(String id) async {
    return (_db.select(_db.timeCapsuleRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<TimeCapsuleRecord>> getAll(String babyId) async {
    return (_db.select(_db.timeCapsuleRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.sealedAt)]))
        .get();
  }

  Future<List<TimeCapsuleRecord>> getSealed(String babyId) async {
    final now = DateTime.now();
    return (_db.select(_db.timeCapsuleRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isUnlocked.equals(false))
          ..where((t) => t.unlockAt.isBiggerThanValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.unlockAt)]))
        .get();
  }

  Future<List<TimeCapsuleRecord>> getReadyToUnlock(String babyId) async {
    final now = DateTime.now();
    return (_db.select(_db.timeCapsuleRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isUnlocked.equals(false))
          ..where((t) => t.unlockAt.isSmallerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.unlockAt)]))
        .get();
  }

  Future<TimeCapsuleRecord?> getNearestUnlocking(String babyId) async {
    final now = DateTime.now();
    return (_db.select(_db.timeCapsuleRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isUnlocked.equals(false))
          ..where((t) => t.unlockAt.isBiggerThanValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.unlockAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<TimeCapsuleRecord>> getUnlocked(String babyId) async {
    return (_db.select(_db.timeCapsuleRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isUnlocked.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.unlockedAt)]))
        .get();
  }

  Future<void> markUnlocked(String id) async {
    await updateById(id, TimeCapsuleRecordsCompanion(
      isUnlocked: const Value(true),
      unlockedAt: Value(DateTime.now()),
    ));
  }
}
