import 'package:drift/drift.dart';

class DiaryRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get content => text()();
  TextColumn get title => text().nullable()();
  TextColumn get mood => text().nullable()();
  TextColumn get imagePaths => text().nullable()();
  DateTimeColumn get recordDate => dateTime()();
  TextColumn get weather => text().nullable()();
  TextColumn get location => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
