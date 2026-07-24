import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/diary_records.dart';

class DiaryRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  DiaryRepository(this._db);

  Future<String> addDiary({
    required String babyId,
    required String content,
    String? title,
    String? mood,
    String? imagePaths,
    required DateTime recordDate,
    String? weather,
    String? location,
    bool isFavorite = false,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.diaryRecords).insert(
          DiaryRecordsCompanion.insert(
            id: id,
            babyId: babyId,
            content: content,
            title: Value(title),
            mood: Value(mood),
            imagePaths: Value(imagePaths),
            recordDate: recordDate,
            weather: Value(weather),
            location: Value(location),
            isFavorite: Value(isFavorite),
          ),
        );
    return id;
  }

  Future<List<DiaryRecord>> getDiariesByBabyId(String babyId) async {
    return (_db.select(_db.diaryRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .get();
  }

  Future<DiaryRecord?> getDiaryById(String id) async {
    return (_db.select(_db.diaryRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<DiaryRecord>> getDiariesByDateRange(
    String babyId,
    DateTime start,
    DateTime end,
  ) async {
    return (_db.select(_db.diaryRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .get();
  }

  Future<List<DiaryRecord>> searchDiaries(
    String babyId,
    String keyword,
  ) async {
    return (_db.select(_db.diaryRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.content.contains(keyword))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .get();
  }

  Future<void> updateDiary(
    String id,
    DiaryRecordsCompanion data,
  ) async {
    await (_db.update(_db.diaryRecords)..where((t) => t.id.equals(id)))
        .write(data.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> deleteDiary(String id) async {
    await (_db.update(_db.diaryRecords)..where((t) => t.id.equals(id))).write(
          DiaryRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> toggleFavorite(String id) async {
    final diary = await getDiaryById(id);
    if (diary != null) {
      await (_db.update(_db.diaryRecords)..where((t) => t.id.equals(id))).write(
            DiaryRecordsCompanion(
              isFavorite: Value(!diary.isFavorite),
              updatedAt: Value(DateTime.now()),
            ),
          );
    }
  }
}
