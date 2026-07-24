import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/hobby_records.dart';

class HobbyRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  HobbyRepository(this._db);

  Future<String> addHobby({
    required String babyId,
    required String hobbyName,
    required int startAgeMonths,
    int? endAgeMonths,
    int? intensity,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.hobbyRecords).insert(
          HobbyRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            hobbyName: hobbyName,
            startAgeMonths: startAgeMonths,
            endAgeMonths: Value(endAgeMonths),
            intensity: Value(intensity),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<HobbyRecord>> getAllHobbies(String babyId) async {
    return (_db.select(_db.hobbyRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startAgeMonths)]))
        .get();
  }

  Future<HobbyRecord?> getHobbyById(String id) async {
    return (_db.select(_db.hobbyRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<void> updateHobby(
    String id, {
    int? endAgeMonths,
    int? intensity,
    String? note,
  }) async {
    await (_db.update(_db.hobbyRecords)..where((t) => t.id.equals(id))).write(
          HobbyRecordsCompanion(
            endAgeMonths: Value(endAgeMonths),
            intensity: Value(intensity),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteHobby(String id) async {
    await (_db.update(_db.hobbyRecords)..where((t) => t.id.equals(id))).write(
          HobbyRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<HobbyRecord>> getActiveHobbies(String babyId) async {
    return (_db.select(_db.hobbyRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.endAgeMonths.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.startAgeMonths)]))
        .get();
  }
}