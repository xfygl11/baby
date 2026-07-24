import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/item_records.dart';

class ItemRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  ItemRepository(this._db);

  Future<ItemRecord> insert(ItemRecordsCompanion entity) async {
    final id = _uuid.v4();
    final companion = entity.copyWith(id: Value(id));
    await _db.into(_db.itemRecords).insert(companion);
    return (_db.select(_db.itemRecords)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<int> updateById(String id, ItemRecordsCompanion entity) async {
    return (_db.update(_db.itemRecords)
          ..where((t) => t.id.equals(id)))
        .write(entity.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<int> deleteById(String id) async {
    return (_db.update(_db.itemRecords)
          ..where((t) => t.id.equals(id)))
        .write(ItemRecordsCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(DateTime.now()),
        ));
  }

  Future<ItemRecord?> getById(String id) async {
    return (_db.select(_db.itemRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<ItemRecord>> getAll(String babyId) async {
    return (_db.select(_db.itemRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .get();
  }

  Future<List<ItemRecord>> getByType(String babyId, String itemType) async {
    return (_db.select(_db.itemRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.itemType.equals(itemType))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .get();
  }

  Future<List<ItemRecord>> getActive(String babyId) async {
    return (_db.select(_db.itemRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.endDate.isNull())
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.itemType), (t) => OrderingTerm.desc(t.startDate)]))
        .get();
  }
}