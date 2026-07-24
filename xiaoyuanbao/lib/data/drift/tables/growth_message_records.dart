import 'package:drift/drift.dart';

@DataClassName('GrowthMessageRecord')
class GrowthMessageRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  IntColumn get age => integer()();
  DateTimeColumn get birthdayDate => dateTime()();
  TextColumn get content => text()();
  TextColumn get audioPath => text().nullable()();
  IntColumn get audioDurationSeconds => integer().nullable().withDefault(const Constant(0))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(true))();
  DateTimeColumn get unlockDate => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}