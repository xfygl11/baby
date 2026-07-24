import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/size_records.dart';

class SizeRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  SizeRepository(this._db);

  Future<SizeRecord> insert(SizeRecordsCompanion entity) async {
    final id = _uuid.v4();
    final companion = entity.copyWith(id: Value(id));
    await _db.into(_db.sizeRecords).insert(companion);
    return (_db.select(_db.sizeRecords)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<int> updateById(String id, SizeRecordsCompanion entity) async {
    return (_db.update(_db.sizeRecords)
          ..where((t) => t.id.equals(id)))
        .write(entity.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<int> deleteById(String id) async {
    return (_db.update(_db.sizeRecords)
          ..where((t) => t.id.equals(id)))
        .write(SizeRecordsCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(DateTime.now()),
        ));
  }

  Future<SizeRecord?> getById(String id) async {
    return (_db.select(_db.sizeRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<SizeRecord>> getAll(String babyId) async {
    return (_db.select(_db.sizeRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sizeType), (t) => OrderingTerm.desc(t.recordDate)]))
        .get();
  }

  Future<List<SizeRecord>> getByType(String babyId, String sizeType) async {
    return (_db.select(_db.sizeRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.sizeType.equals(sizeType))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .get();
  }

  Future<SizeRecord?> getCurrentSize(String babyId, String sizeType) async {
    final records = await getByType(babyId, sizeType);
    return records.isNotEmpty ? records.first : null;
  }
}