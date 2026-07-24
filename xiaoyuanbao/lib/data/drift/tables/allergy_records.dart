import 'package:drift/drift.dart';

@DataClassName('AllergyRecord')
class AllergyRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get allergen => text().withLength(min: 1, max: 100)();
  TextColumn get reaction => text().withLength(min: 1, max: 500)();
  IntColumn get severity => intEnum<AllergySeverity>()();
  DateTimeColumn get firstOccurrence => dateTime()();
  DateTimeColumn get lastOccurrence => dateTime().nullable()();
  TextColumn get treatment => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable();

  @override
  Set<Column> get primaryKey => {id};
}

enum AllergySeverity { mild, moderate, severe, emergency }