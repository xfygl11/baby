import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/interest_class_records.dart';

class InterestClassRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  InterestClassRepository(this._db);

  Future<String> addInterestClass({
    required String babyId,
    required InterestType interestType,
    required String className,
    required String organization,
    required DateTime startDate,
    DateTime? endDate,
    String? level,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.interestClassRecords).insert(
          InterestClassRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            interestType: interestType,
            className: className,
            organization: organization,
            startDate: startDate,
            endDate: Value(endDate),
            level: Value(level),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<InterestClassRecord>> getAllInterestClasses(String babyId) async {
    return (_db.select(_db.interestClassRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .get();
  }

  Future<InterestClassRecord?> getInterestClassById(String id) async {
    return (_db.select(_db.interestClassRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<void> updateInterestClass(
    String id, {
    String? level,
    DateTime? endDate,
    String? note,
  }) async {
    await (_db.update(_db.interestClassRecords)..where((t) => t.id.equals(id))).write(
          InterestClassRecordsCompanion(
            level: Value(level),
            endDate: Value(endDate),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteInterestClass(String id) async {
    await (_db.update(_db.interestClassRecords)..where((t) => t.id.equals(id))).write(
          InterestClassRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<InterestClassRecord>> getActiveInterestClasses(String babyId) async {
    return (_db.select(_db.interestClassRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.endDate.isNull() | t.endDate.isBiggerThanValue(DateTime.now()))
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .get();
  }
}