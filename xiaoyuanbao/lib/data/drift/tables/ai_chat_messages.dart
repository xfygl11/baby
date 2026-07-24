import 'package:drift/drift.dart';

class AiChatMessages extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  IntColumn get role => integer()();
  TextColumn get content => text()();
  TextColumn get intent => text().nullable()();
  TextColumn get entitiesJson => text().nullable()();
  TextColumn get relatedRecordIds => text().nullable()();
  TextColumn get messageType => text().withDefault(const Constant('text'))();
  BoolColumn get hasConfirmed => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
