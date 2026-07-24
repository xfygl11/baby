import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/milestone_records.dart';

class MilestoneRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  MilestoneRepository(this._db);

  Future<String> addMilestone({
    required String babyId,
    required String name,
    required int category,
    DateTime? achieveDate,
    String? description,
    String? imagePath,
    bool isCustom = false,
    String? templateId,
    String? note,
    int? expectedAgeMonths,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.milestoneRecords).insert(
          MilestoneRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            name: name,
            category: category,
            achieveDate: Value(achieveDate),
            description: Value(description),
            imagePath: Value(imagePath),
            isCustom: Value(isCustom),
            templateId: Value(templateId),
            note: Value(note),
            expectedAgeMonths: Value(expectedAgeMonths),
          ),
        );
    return id;
  }

  Future<List<MilestoneRecord>> getMilestonesByBabyId(String babyId) async {
    return (_db.select(_db.milestoneRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<MilestoneRecord?> getMilestoneById(String id) async {
    return (_db.select(_db.milestoneRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<MilestoneRecord>> getMilestonesByCategory(
    String babyId,
    int category,
  ) async {
    return (_db.select(_db.milestoneRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.category.equals(category))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<List<MilestoneRecord>> getAchievedMilestones(String babyId) async {
    return (_db.select(_db.milestoneRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.achieveDate.isNotNull())
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.achieveDate)]))
        .get();
  }

  Future<void> updateMilestone(
    String id,
    MilestoneRecordsCompanion data,
  ) async {
    await (_db.update(_db.milestoneRecords)..where((t) => t.id.equals(id)))
        .write(data.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> deleteMilestone(String id) async {
    await (_db.update(_db.milestoneRecords)..where((t) => t.id.equals(id)))
        .write(
          MilestoneRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> batchInsertMilestones(
    String babyId,
    List<MilestoneRecordsCompanion> milestones,
  ) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.milestoneRecords,
        milestones
            .map((m) => m.copyWith(
                  id: Value(_uuid.v4()),
                  babyId: Value(babyId),
                ))
            .toList(),
      );
    });
  }
}
