import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/parent_meeting_records.dart';

class ParentMeetingRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  ParentMeetingRepository(this._db);

  Future<String> addParentMeeting({
    required String babyId,
    required DateTime meetingDate,
    required String teacherComments,
    String? keyPoints,
    String? improvementPlan,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.parentMeetingRecords).insert(
          ParentMeetingRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            meetingDate: meetingDate,
            teacherComments: teacherComments,
            keyPoints: Value(keyPoints),
            improvementPlan: Value(improvementPlan),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<ParentMeetingRecord>> getAllParentMeetings(String babyId) async {
    return (_db.select(_db.parentMeetingRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.meetingDate)]))
        .get();
  }

  Future<ParentMeetingRecord?> getParentMeetingById(String id) async {
    return (_db.select(_db.parentMeetingRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<void> updateParentMeeting(
    String id, {
    String? teacherComments,
    String? keyPoints,
    String? improvementPlan,
    String? note,
  }) async {
    await (_db.update(_db.parentMeetingRecords)..where((t) => t.id.equals(id))).write(
          ParentMeetingRecordsCompanion(
            teacherComments: Value(teacherComments),
            keyPoints: Value(keyPoints),
            improvementPlan: Value(improvementPlan),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteParentMeeting(String id) async {
    await (_db.update(_db.parentMeetingRecords)..where((t) => t.id.equals(id))).write(
          ParentMeetingRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}