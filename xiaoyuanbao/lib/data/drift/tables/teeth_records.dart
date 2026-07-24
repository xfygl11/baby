import 'package:drift/drift.dart';

@DataClassName('TeethRecord')
class TeethRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  IntColumn get eventType => intEnum<TeethEventType>()();
  TextColumn get position => text().withLength(min: 1, max: 10)();
  TextColumn get positionName => text().withLength(min: 1, max: 50)();
  DateTimeColumn get eventDate => dateTime()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum TeethEventType { eruption, shedding, permanentEruption, checkup }