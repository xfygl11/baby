import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/skin_records.dart';

class SkinRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  SkinRepository(this._db);

  Future<String> addSkin({
    required String babyId,
    required DateTime time,
    required SkinCondition condition,
    String? location,
    required Severity severity,
    String? treatment,
    String? imagePath,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.skinRecords).insert(
          SkinRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            time: time,
            condition: condition,
            location: Value(location),
            severity: severity,
            treatment: Value(treatment),
            imagePath: Value(imagePath),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<SkinRecord>> getAllSkin(String babyId) async {
    return (_db.select(_db.skinRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.time)]))
        .get();
  }

  Future<SkinRecord?> getSkinById(String id) async {
    return (_db.select(_db.skinRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateSkin(
    String id, {
    SkinCondition? condition,
    String? location,
    Severity? severity,
    String? treatment,
    String? imagePath,
    String? note,
  }) async {
    await (_db.update(_db.skinRecords)..where((t) => t.id.equals(id))).write(
          SkinRecordsCompanion(
            condition: condition != null ? Value(condition) : const Value.absent(),
            location: Value(location),
            severity: severity != null ? Value(severity) : const Value.absent(),
            treatment: Value(treatment),
            imagePath: Value(imagePath),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteSkin(String id) async {
    await (_db.update(_db.skinRecords)..where((t) => t.id.equals(id))).write(
          SkinRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<SkinRecord>> getActiveConditions(String babyId) async {
    return (_db.select(_db.skinRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.time)]))
        .get();
  }
}