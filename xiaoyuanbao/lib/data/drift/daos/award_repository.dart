import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/award_records.dart';

class AwardRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  AwardRepository(this._db);

  Future<String> addAward({
    required String babyId,
    required String awardName,
    required AwardLevel awardLevel,
    required DateTime awardDate,
    required String awardingOrganization,
    String? certificatePath,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.awardRecords).insert(
          AwardRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            awardName: awardName,
            awardLevel: awardLevel,
            awardDate: awardDate,
            awardingOrganization: awardingOrganization,
            certificatePath: Value(certificatePath),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<AwardRecord>> getAllAwards(String babyId) async {
    return (_db.select(_db.awardRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.awardDate)]))
        .get();
  }

  Future<AwardRecord?> getAwardById(String id) async {
    return (_db.select(_db.awardRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<void> updateAward(
    String id, {
    String? awardingOrganization,
    String? certificatePath,
    String? note,
  }) async {
    await (_db.update(_db.awardRecords)..where((t) => t.id.equals(id))).write(
          AwardRecordsCompanion(
            awardingOrganization: Value(awardingOrganization),
            certificatePath: Value(certificatePath),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteAward(String id) async {
    await (_db.update(_db.awardRecords)..where((t) => t.id.equals(id))).write(
          AwardRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<AwardRecord>> getAwardsByLevel(String babyId, int level) async {
    return (_db.select(_db.awardRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.awardLevel.equals(level))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.awardDate)]))
        .get();
  }
}