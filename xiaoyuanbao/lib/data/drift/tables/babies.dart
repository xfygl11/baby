import 'package:drift/drift.dart';

enum BabyGender { male, female, unknown }

class Babies extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get nickname => text().withLength(max: 30).nullable()();
  DateTimeColumn get birthDate => dateTime()();
  TextColumn get birthTime => text().nullable()();
  IntColumn get gender => intEnum<BabyGender>()();
  RealColumn get birthWeight => real().nullable()();
  RealColumn get birthHeight => real().nullable()();
  RealColumn get birthHeadCircumference => real().nullable()();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
