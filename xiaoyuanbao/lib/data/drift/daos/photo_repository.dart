import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/photo_records.dart';

class PhotoRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  PhotoRepository(this._db);

  Future<String> addPhoto({
    required String babyId,
    required String filePath,
    String? thumbnailPath,
    String? title,
    String? description,
    required DateTime captureDate,
    String? location,
    required int width,
    required int height,
    required double sizeMb,
    bool isFavorite = false,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.photoRecords).insert(
          PhotoRecordsCompanion(
            id: Value(id),
            babyId: Value(babyId),
            filePath: Value(filePath),
            thumbnailPath: Value(thumbnailPath),
            title: Value(title),
            description: Value(description),
            captureDate: Value(captureDate),
            location: Value(location),
            width: Value(width),
            height: Value(height),
            sizeMb: Value(sizeMb),
            isFavorite: Value(isFavorite),
          ),
        );
    return id;
  }

  Future<void> updatePhoto(
    String id,
    PhotoRecordsCompanion companion,
  ) async {
    await (_db.update(_db.photoRecords)
          ..where((t) => t.id.equals(id)))
        .write(companion.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> deletePhoto(String id) async {
    await (_db.update(_db.photoRecords)
          ..where((t) => t.id.equals(id)))
        .write(
          PhotoRecordsCompanion(
            isDeleted: const Value(true),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> toggleFavorite(String id) async {
    final photo = await getPhotoById(id);
    if (photo != null) {
      await updatePhoto(
        id,
        PhotoRecordsCompanion(isFavorite: Value(!photo.isFavorite)),
      );
    }
  }

  Future<PhotoRecord?> getPhotoById(String id) async {
    return await (_db.select(_db.photoRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<PhotoRecord>> getPhotosByBabyId(String babyId) async {
    return await (_db.select(_db.photoRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.captureDate)]))
        .get();
  }

  Future<List<PhotoRecord>> getFavoritePhotos(String babyId) async {
    return await (_db.select(_db.photoRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isFavorite.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.captureDate)]))
        .get();
  }

  Future<List<PhotoRecord>> getPhotosByMonth(String babyId, int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    return await (_db.select(_db.photoRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.captureDate.isBiggerOrEqualValue(startDate))
          ..where((t) => t.captureDate.isSmallerThanValue(endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.captureDate)]))
        .get();
  }

  Future<int> getPhotoCount(String babyId) async {
    return await (_db.selectOnly(_db.photoRecords)
          ..addColumns([_db.photoRecords.id.count()])
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false)))
        .map((row) => row.read(_db.photoRecords.id.count()!)!)
        .getSingle();
  }

  Future<List<Map<String, dynamic>>> getPhotoStatsByMonth(String babyId) async {
    final records = await getPhotosByBabyId(babyId);
    final stats = <String, int>{};

    for (final record in records) {
      final key = '${record.captureDate.year}-${record.captureDate.month.toString().padLeft(2, '0')}';
      stats[key] = (stats[key] ?? 0) + 1;
    }

    return stats.entries
        .map((e) => {'month': e.key, 'count': e.value})
        .toList()
      ..sort((a, b) => b['month'].compareTo(a['month']));
  }
}