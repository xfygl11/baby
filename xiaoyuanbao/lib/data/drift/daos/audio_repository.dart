import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/audio_records.dart';

class AudioRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  AudioRepository(this._db);

  Future<String> addAudio({
    required String babyId,
    required String filePath,
    String? title,
    String? description,
    required DateTime recordDate,
    required int durationSeconds,
    required double sizeMb,
    bool isFavorite = false,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.audioRecords).insert(
          AudioRecordsCompanion(
            id: Value(id),
            babyId: Value(babyId),
            filePath: Value(filePath),
            title: Value(title),
            description: Value(description),
            recordDate: Value(recordDate),
            durationSeconds: Value(durationSeconds),
            sizeMb: Value(sizeMb),
            isFavorite: Value(isFavorite),
          ),
        );
    return id;
  }

  Future<void> updateAudio(
    String id,
    AudioRecordsCompanion companion,
  ) async {
    await (_db.update(_db.audioRecords)
          ..where((t) => t.id.equals(id)))
        .write(companion.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> deleteAudio(String id) async {
    await (_db.update(_db.audioRecords)
          ..where((t) => t.id.equals(id)))
        .write(
          AudioRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> toggleFavorite(String id) async {
    final audio = await getAudioById(id);
    if (audio != null) {
      await updateAudio(
        id,
        AudioRecordsCompanion(isFavorite: Value(!audio.isFavorite)),
      );
    }
  }

  Future<AudioRecord?> getAudioById(String id) async {
    return await (_db.select(_db.audioRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<AudioRecord>> getAudiosByBabyId(String babyId) async {
    return await (_db.select(_db.audioRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .get();
  }

  Future<List<AudioRecord>> getFavoriteAudios(String babyId) async {
    return await (_db.select(_db.audioRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isFavorite.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .get();
  }

  Future<List<AudioRecord>> getAudiosByMonth(String babyId, int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    return await (_db.select(_db.audioRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(startDate))
          ..where((t) => t.recordDate.isSmallerThanValue(endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .get();
  }

  Future<AudioRecord?> getLatestAudio(String babyId) async {
    return await (_db.select(_db.audioRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> getAudioCount(String babyId) async {
    return await (_db.selectOnly(_db.audioRecords)
          ..addColumns([_db.audioRecords.id.count()])
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false)))
        .map((row) => row.read(_db.audioRecords.id.count()!)!)
        .getSingle();
  }

  Future<double> getTotalDurationMinutes(String babyId) async {
    final records = await getAudiosByBabyId(babyId);
    return records.fold(0.0, (sum, r) => sum + r.durationSeconds / 60);
  }
}