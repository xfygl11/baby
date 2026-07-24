import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/allergy_records.dart';

class AllergyRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  AllergyRepository(this._db);

  Future<String> addAllergy({
    required String babyId,
    required String allergen,
    required String reaction,
    required AllergySeverity severity,
    required DateTime firstOccurrence,
    DateTime? lastOccurrence,
    String? treatment,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.allergyRecords).insert(
          AllergyRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            allergen: allergen,
            reaction: reaction,
            severity: severity.index,
            firstOccurrence: firstOccurrence,
            lastOccurrence: Value(lastOccurrence),
            treatment: Value(treatment),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<AllergyRecord>> getAllAllergies(String babyId) async {
    return (_db.select(_db.allergyRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.firstOccurrence)]))
        .get();
  }

  Future<AllergyRecord?> getAllergyById(String id) async {
    return (_db.select(_db.allergyRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateAllergy(
    String id, {
    String? reaction,
    AllergySeverity? severity,
    DateTime? lastOccurrence,
    String? treatment,
    String? note,
  }) async {
    await (_db.update(_db.allergyRecords)..where((t) => t.id.equals(id))).write(
          AllergyRecordsCompanion(
            reaction: Value(reaction),
            severity: severity != null ? Value(severity.index) : const Value.absent(),
            lastOccurrence: Value(lastOccurrence),
            treatment: Value(treatment),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteAllergy(String id) async {
    await (_db.update(_db.allergyRecords)..where((t) => t.id.equals(id))).write(
          AllergyRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}