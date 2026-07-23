import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../drift/app_database.dart';
import '../drift/tables/babies.dart';

class BabyRepository {
  final AppDatabase _db = AppDatabase.instance;
  final Uuid _uuid = const Uuid();

  Future<String> createBaby({
    required String name,
    required DateTime birthDate,
    required int gender,
    String? nickname,
    String? birthTime,
    double? birthWeight,
    double? birthHeight,
    double? birthHeadCircumference,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.babies).insert(
          BabiesCompanion.insert(
            id: id,
            name: name,
            nickname: Value(nickname),
            birthDate: birthDate,
            birthTime: Value(birthTime),
            gender: gender,
            birthWeight: Value(birthWeight),
            birthHeight: Value(birthHeight),
            birthHeadCircumference: Value(birthHeadCircumference),
            note: Value(note),
          ),
        );
    return id;
  }

  Future<Baby?> getBabyById(String id) async {
    return (_db.select(_db.babies)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<Baby?> getActiveBaby() async {
    return (_db.select(_db.babies)
          ..where((t) => t.isActive.equals(true))
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<Baby?> watchActiveBaby() {
    return (_db.select(_db.babies)
          ..where((t) => t.isActive.equals(true))
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<List<Baby>> getAllBabies() async {
    return (_db.select(_db.babies)..where((t) => t.isDeleted.equals(false))).get();
  }

  Future<void> updateBaby(String id, {
    String? name,
    String? nickname,
    DateTime? birthDate,
    String? birthTime,
    int? gender,
    double? birthWeight,
    double? birthHeight,
    String? avatarPath,
    String? note,
  }) async {
    await (_db.update(_db.babies)..where((t) => t.id.equals(id))).write(
          BabiesCompanion(
            name: name != null ? Value(name) : const Value.absent(),
            nickname: nickname != null ? Value(nickname) : const Value.absent(),
            birthDate: birthDate != null ? Value(birthDate) : const Value.absent(),
            birthTime: birthTime != null ? Value(birthTime) : const Value.absent(),
            gender: gender != null ? Value(gender) : const Value.absent(),
            birthWeight: birthWeight != null ? Value(birthWeight) : const Value.absent(),
            birthHeight: birthHeight != null ? Value(birthHeight) : const Value.absent(),
            avatarPath: avatarPath != null ? Value(avatarPath) : const Value.absent(),
            note: note != null ? Value(note) : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> setActiveBaby(String id) async {
    await _db.transaction(() async {
      await (_db.update(_db.babies)).write(const BabiesCompanion(isActive: Value(false)));
      await (_db.update(_db.babies)..where((t) => t.id.equals(id))).write(
            BabiesCompanion(isActive: const Value(true), updatedAt: Value(DateTime.now())),
          );
    });
  }

  Future<void> deleteBaby(String id) async {
    await (_db.update(_db.babies)..where((t) => t.id.equals(id))).write(
          BabiesCompanion(
            isDeleted: const Value(true),
            isActive: const Value(false),
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}
