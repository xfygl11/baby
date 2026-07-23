import 'package:drift/drift.dart';

enum ChatRole { user, assistant, system }
enum ChatMode { normal, record, query, confirm }
enum ChatStatus { sending, sent, failed, deleted }

class AiChatMessages extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get sessionId => text().withLength(min: 36, max: 36)();
  IntColumn get role => intEnum<ChatRole>()();
  TextColumn get content => text()();
  IntColumn get mode => intEnum<ChatMode>().withDefault(const Constant(0))();
  TextColumn get detectedIntent => text().nullable()();
  TextColumn get extractedEntities => text().nullable()();
  TextColumn get relatedRecordId => text().nullable()();
  TextColumn get relatedRecordType => text().nullable()();
  IntColumn get status => intEnum<ChatStatus>().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
