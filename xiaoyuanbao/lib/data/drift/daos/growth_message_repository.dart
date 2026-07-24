import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/growth_message_records.dart';

class GrowthMessageRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  GrowthMessageRepository(this._db);

  Future<GrowthMessageRecord> insert(GrowthMessageRecordsCompanion entity) async {
    final id = _uuid.v4();
    final companion = entity.copyWith(id: Value(id));
    final insertedId = await _db.into(_db.growthMessageRecords).insert(companion);
    return _db.growthMessageRecords.get(insertedId);
  }

  Future<int> updateById(String id, GrowthMessageRecordsCompanion entity) async {
    return _db.update(_db.growthMessageRecords)
      ..where((t) => t.id.equals(id))
      ..write(entity.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<int> deleteById(String id) async {
    return _db.update(_db.growthMessageRecords)
      ..where((t) => t.id.equals(id))
      ..write(GrowthMessageRecordsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
      ));
  }

  Future<GrowthMessageRecord?> getById(String id) async {
    return (_db.select(_db.growthMessageRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<GrowthMessageRecord>> getAll(String babyId) async {
    return (_db.select(_db.growthMessageRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.age)]))
        .get();
  }

  Future<List<GrowthMessageRecord>> getUnlocked(String babyId) async {
    return (_db.select(_db.growthMessageRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isLocked.equals(false))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.age)]))
        .get();
  }

  Future<List<GrowthMessageRecord>> getLocked(String babyId) async {
    return (_db.select(_db.growthMessageRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isLocked.equals(true))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.age)]))
        .get();
  }

  Future<GrowthMessageRecord?> getByAge(String babyId, int age) async {
    return (_db.select(_db.growthMessageRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.age.equals(age))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<int> unlockMessage(String id) async {
    return _db.update(_db.growthMessageRecords)
      ..where((t) => t.id.equals(id))
      ..write(GrowthMessageRecordsCompanion(
        isLocked: const Value(false),
        updatedAt: Value(DateTime.now()),
      ));
  }
}