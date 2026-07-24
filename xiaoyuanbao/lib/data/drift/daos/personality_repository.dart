import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/personality_records.dart';

class PersonalityRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  PersonalityRepository(this._db);

  Future<String> addPersonality({
    required String babyId,
    required PersonalityTrait trait,
    required DateTime observationDate,
    required String description,
    String? context,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.personalityRecords).insert(
          PersonalityRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            trait: trait,
            observationDate: observationDate,
            description: description,
            context: Value(context),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<PersonalityRecord>> getAllPersonality(String babyId) async {
    return (_db.select(_db.personalityRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.observationDate)]))
        .get();
  }

  Future<PersonalityRecord?> getPersonalityById(String id) async {
    return (_db.select(_db.personalityRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<void> updatePersonality(
    String id, {
    String? description,
    String? context,
    String? note,
  }) async {
    await (_db.update(_db.personalityRecords)..where((t) => t.id.equals(id))).write(
          PersonalityRecordsCompanion(
            description: description != null ? Value(description) : const Value.absent(),
            context: Value(context),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deletePersonality(String id) async {
    await (_db.update(_db.personalityRecords)..where((t) => t.id.equals(id))).write(
          PersonalityRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}