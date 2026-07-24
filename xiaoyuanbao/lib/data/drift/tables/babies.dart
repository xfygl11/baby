import 'package:drift/drift.dart';

class Babies extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get gender => intEnum<BabyGenderEnum>().withDefault(const Constant(2))();
  DateTimeColumn get birthDate => dateTime()();
  RealColumn get birthWeight => real().nullable()();
  RealColumn get birthHeight => real().nullable()();
  RealColumn get birthHeadCircumference => real().nullable()();
  TextColumn get bloodType => text().nullable()();
  RealColumn get fatherHeight => real().nullable()();
  RealColumn get motherHeight => real().nullable()();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get zodiacSign => text().nullable()();
  TextColumn get constellation => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

enum BabyGenderEnum { female, male, unknown }
