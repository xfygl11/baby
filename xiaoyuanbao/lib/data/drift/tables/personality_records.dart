import 'package:drift/drift.dart';

class PersonalityRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  IntColumn get trait => intEnum<PersonalityTrait>()();
  DateTimeColumn get observationDate => dateTime()();
  TextColumn get description => text()();
  TextColumn get context => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable();

  @override
  Set<Column> get primaryKey => {id};
}

enum PersonalityTrait { bold, cautious, extroverted, introverted, sensitive, resilient, curious, creative, patient, impulsive }