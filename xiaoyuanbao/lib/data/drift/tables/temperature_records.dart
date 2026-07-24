import 'package:drift/drift.dart';

class TemperatureRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  RealColumn get temperature => real()();
  IntColumn get site => intEnum<TemperatureSiteEnum>().withDefault(const Constant(0))();
  DateTimeColumn get recordTime => dateTime()();
  TextColumn get note => text().nullable()();
  BoolColumn get isFever => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum TemperatureSiteEnum { armpit, ear, forehead, rectal, oral }
