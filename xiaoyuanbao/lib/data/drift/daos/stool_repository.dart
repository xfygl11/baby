import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/stool_records.dart';

class StoolRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  StoolRepository(this._db);

  Future<String> addStool({
    required String babyId,
    required DateTime time,
    required StoolColor color,
    required BristolType bristolType,
    String? amount,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.stoolRecords).insert(
          StoolRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            time: time,
            color: color.index,
            bristolType: bristolType.index,
            amount: Value(amount),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<StoolRecord>> getAllStool(String babyId) async {
    return (_db.select(_db.stoolRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.time)]))
        .get();
  }

  Future<StoolRecord?> getStoolById(String id) async {
    return (_db.select(_db.stoolRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateStool(
    String id, {
    StoolColor? color,
    BristolType? bristolType,
    String? amount,
    String? note,
  }) async {
    await (_db.update(_db.stoolRecords)..where((t) => t.id.equals(id))).write(
          StoolRecordsCompanion(
            color: color != null ? Value(color.index) : const Value.absent(),
            bristolType: bristolType != null ? Value(bristolType.index) : const Value.absent(),
            amount: Value(amount),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteStool(String id) async {
    await (_db.update(_db.stoolRecords)..where((t) => t.id.equals(id))).write(
          StoolRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<StoolRecord>> getStoolByDateRange(
    String babyId,
    DateTime start,
    DateTime end,
  ) async {
    return (_db.select(_db.stoolRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.time.isBiggerOrEqualValue(start))
          ..where((t) => t.time.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.time)]))
        .get();
  }
}