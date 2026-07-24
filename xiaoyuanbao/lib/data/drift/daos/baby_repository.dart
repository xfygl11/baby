import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/babies.dart';

class BabyRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  BabyRepository(this._db);

  Future<String> addBaby({
    required String name,
    required int gender,
    required DateTime birthDate,
    double? birthWeight,
    double? birthHeight,
    double? birthHeadCircumference,
    String? bloodType,
    double? fatherHeight,
    double? motherHeight,
    String? avatarPath,
    String? zodiacSign,
    String? constellation,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.babies).insert(
          BabiesCompanion.insert(
            id: id,
            name: name,
            gender: Value(BabyGenderEnum.values[gender]),
            birthDate: birthDate,
            birthWeight: Value(birthWeight),
            birthHeight: Value(birthHeight),
            birthHeadCircumference: Value(birthHeadCircumference),
            bloodType: Value(bloodType),
            fatherHeight: Value(fatherHeight),
            motherHeight: Value(motherHeight),
            avatarPath: Value(avatarPath),
            zodiacSign: Value(zodiacSign),
            constellation: Value(constellation),
          ),
        );
    return id;
  }

  Future<Baby?> getActiveBaby() async {
    return (_db.select(_db.babies)
          ..where((t) => t.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Baby?> getBabyById(String id) async {
    return (_db.select(_db.babies)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Baby>> getAllBabies() async {
    return (_db.select(_db.babies)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<void> updateBaby(String id, BabiesCompanion data) async {
    await (_db.update(_db.babies)..where((t) => t.id.equals(id)))
        .write(data.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> updateBabyName(String id, String name) async {
    await (_db.update(_db.babies)..where((t) => t.id.equals(id))).write(
          BabiesCompanion(
            name: Value(name),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> setActiveBaby(String id) async {
    await _db.transaction(() async {
      await (_db.update(_db.babies)).write(
            BabiesCompanion(
              isActive: const Value(false),
              updatedAt: Value(DateTime.now()),
            ),
          );
      await (_db.update(_db.babies)..where((t) => t.id.equals(id))).write(
            BabiesCompanion(
              isActive: const Value(true),
              updatedAt: Value(DateTime.now()),
            ),
          );
    });
  }

  Future<void> deleteBaby(String id) async {
    await (_db.update(_db.babies)..where((t) => t.id.equals(id))).write(
          BabiesCompanion(
            isActive: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}
