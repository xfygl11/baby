import 'package:drift/drift.dart';

class AppSettings extends Table {
  TextColumn get key => text().withLength(min: 1, max: 100)();
  TextColumn get value => text().nullable()();
  TextColumn get valueType => text().withDefault(const Constant('string'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}
