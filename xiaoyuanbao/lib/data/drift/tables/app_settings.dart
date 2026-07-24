import 'package:drift/drift.dart';

class AppSettings extends Table {
  TextColumn get id => text().withLength(min: 1, max: 50)();
  TextColumn get value => text().nullable()();
  TextColumn get type => text().withDefault(const Constant('string'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
