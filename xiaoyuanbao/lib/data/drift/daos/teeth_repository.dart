import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/teeth_records.dart';

class TeethRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  TeethRepository(this._db);

  Future<String> addTeeth({
    required String babyId,
    required TeethEventType eventType,
    required String position,
    required String positionName,
    required DateTime eventDate,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.teethRecords).insert(
          TeethRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            eventType: eventType,
            position: position,
            positionName: positionName,
            eventDate: eventDate,
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<TeethRecord>> getAllTeeth(String babyId) async {
    return (_db.select(_db.teethRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.eventDate)]))
        .get();
  }

  Future<TeethRecord?> getTeethById(String id) async {
    return (_db.select(_db.teethRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateTeeth(
    String id, {
    DateTime? eventDate,
    String? note,
  }) async {
    await (_db.update(_db.teethRecords)..where((t) => t.id.equals(id))).write(
          TeethRecordsCompanion(
            eventDate: eventDate != null ? Value(eventDate) : const Value.absent(),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteTeeth(String id) async {
    await (_db.update(_db.teethRecords)..where((t) => t.id.equals(id))).write(
          TeethRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<TeethRecord>> getEruptedTeeth(String babyId) async {
    return (_db.select(_db.teethRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.eventType.equals(TeethEventType.eruption.index))
          ..orderBy([(t) => OrderingTerm.asc(t.eventDate)]))
        .get();
  }

  Future<List<TeethRecord>> getShedTeeth(String babyId) async {
    return (_db.select(_db.teethRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.eventType.equals(TeethEventType.shedding.index))
          ..orderBy([(t) => OrderingTerm.asc(t.eventDate)]))
        .get();
  }
}