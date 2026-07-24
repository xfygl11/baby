import 'package:drift/drift.dart';

@DataClassName('SkinRecord')
class SkinRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  DateTimeColumn get time => dateTime()();
  IntColumn get condition => intEnum<SkinCondition>()();
  TextColumn get location => text().nullable()();
  IntColumn get severity => intEnum<Severity>()();
  TextColumn get treatment => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum SkinCondition { eczema, heatRash, diaperRash, acne, dry, other }
enum Severity { mild, moderate, severe }