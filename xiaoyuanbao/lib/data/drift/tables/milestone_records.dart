import 'package:drift/drift.dart';

enum MilestoneCategory {
  motor,
  language,
  cognitive,
  social,
  feeding,
  other,
}

class MilestoneRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get category => intEnum<MilestoneCategory>().withDefault(const Constant(0))();
  DateTimeColumn get achieveDate => dateTime().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get images => text().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  TextColumn get templateId => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
