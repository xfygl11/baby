import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/emotion_records.dart';

class EmotionRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  EmotionRepository(this._db);

  Future<String> addEmotion({
    required String babyId,
    required EmotionType emotionType,
    required DateTime recordTime,
    String? triggerEvent,
    String? description,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.emotionRecords).insert(
          EmotionRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            emotionType: emotionType,
            recordTime: recordTime,
            triggerEvent: Value(triggerEvent),
            description: Value(description),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<List<EmotionRecord>> getAllEmotions(String babyId) async {
    return (_db.select(_db.emotionRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
        .get();
  }

  Future<EmotionRecord?> getEmotionById(String id) async {
    return (_db.select(_db.emotionRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<void> updateEmotion(
    String id, {
    String? triggerEvent,
    String? description,
    String? note,
  }) async {
    await (_db.update(_db.emotionRecords)..where((t) => t.id.equals(id))).write(
          EmotionRecordsCompanion(
            triggerEvent: Value(triggerEvent),
            description: Value(description),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteEmotion(String id) async {
    await (_db.update(_db.emotionRecords)..where((t) => t.id.equals(id))).write(
          EmotionRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<EmotionRecord>> getEmotionsByDateRange(
    String babyId,
    DateTime start,
    DateTime end,
  ) async {
    return (_db.select(_db.emotionRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordTime.isBiggerOrEqualValue(start))
          ..where((t) => t.recordTime.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)]))
        .get();
  }

  Future<EmotionRecord?> getLatestEmotion(String babyId) async {
    return (_db.select(_db.emotionRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordTime)])
          ..limit(1))
        .getSingleOrNull();
  }
}