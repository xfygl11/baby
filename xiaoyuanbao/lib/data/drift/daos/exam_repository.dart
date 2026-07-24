import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/exam_records.dart';

class ExamRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  ExamRepository(this._db);

  Future<String> addExam({
    required String babyId,
    required String examName,
    required ExamType examType,
    required String subject,
    required double score,
    double? fullScore,
    int? rank,
    required DateTime examDate,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.examRecords).insert(
          ExamRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            examName: examName,
            examType: examType,
            subject: subject,
            score: score,
            fullScore: Value(fullScore),
            rank: Value(rank),
            examDate: examDate,
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<ExamRecord>> getAllExams(String babyId) async {
    return (_db.select(_db.examRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.examDate)]))
        .get();
  }

  Future<ExamRecord?> getExamById(String id) async {
    return (_db.select(_db.examRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<void> updateExam(
    String id, {
    double? score,
    double? fullScore,
    int? rank,
    String? note,
  }) async {
    await (_db.update(_db.examRecords)..where((t) => t.id.equals(id))).write(
          ExamRecordsCompanion(
            score: Value(score),
            fullScore: Value(fullScore),
            rank: Value(rank),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteExam(String id) async {
    await (_db.update(_db.examRecords)..where((t) => t.id.equals(id))).write(
          ExamRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<ExamRecord>> getExamsBySubject(String babyId, String subject) async {
    return (_db.select(_db.examRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.subject.equals(subject))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.examDate)]))
        .get();
  }

  Future<List<ExamRecord>> getExamsByDateRange(
    String babyId,
    DateTime start,
    DateTime end,
  ) async {
    return (_db.select(_db.examRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.examDate.isBiggerOrEqualValue(start))
          ..where((t) => t.examDate.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.examDate)]))
        .get();
  }
}