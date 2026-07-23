import 'package:drift/drift.dart';

enum DiaryMood { veryHappy, happy, normal, sad, verySad }

class DiaryRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get title => text().withLength(max: 100).nullable()();
  TextColumn get content => text()();
  DateTimeColumn get recordDate => dateTime()();
  IntColumn get mood => intEnum<DiaryMood>().nullable()();
  TextColumn get tags => text().nullable()();
  TextColumn get images => text().nullable()();
  BoolColumn get isMilestone => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
