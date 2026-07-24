import 'package:drift/drift.dart';

class SleepRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  IntColumn get type => intEnum<SleepTypeEnum>().withDefault(const Constant(0))();
  IntColumn get location => intEnum<SleepLocationEnum>().withDefault(const Constant(0))();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get durationMinutes => integer().nullable()();
  IntColumn get nightWakings => integer().withDefault(const Constant(0))();
  TextColumn get quality => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable();

  @override
  Set<Column> get primaryKey => {id};
}

enum SleepTypeEnum { night, nap, micro }
enum SleepLocationEnum { crib, bed, stroller, carSeat, carrier, other }
