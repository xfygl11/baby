import 'package:drift/drift.dart';

class EmotionRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  IntColumn get emotionType => intEnum<EmotionType>()();
  DateTimeColumn get recordTime => dateTime()();
  TextColumn get triggerEvent => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable();

  @override
  Set<Column> get primaryKey => {id};
}

enum EmotionType { happy, sad, angry, anxious, excited, calm, jealous, proud, shy, tired }