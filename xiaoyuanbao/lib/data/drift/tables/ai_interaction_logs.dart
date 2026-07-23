import 'package:drift/drift.dart';

enum AiInteractionType { text, voice, quickAction }
enum AiInteractionResult { success, partial, failed, cancelled, confirmation }

class AiInteractionLogs extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get babyId => text().withLength(min: 36, max: 36)();
  TextColumn get sessionId => text().withLength(min: 36, max: 36)();
  IntColumn get type => intEnum<AiInteractionType>().withDefault(const Constant(0))();
  TextColumn get userInput => text()();
  IntColumn get result => intEnum<AiInteractionResult>().withDefault(const Constant(0))();
  TextColumn get detectedIntent => text().nullable()();
  RealColumn get intentConfidence => real().nullable()();
  TextColumn get extractedEntities => text().nullable()();
  TextColumn get aiResponse => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  IntegerColumn get responseTimeMs => integer().nullable()();
  TextColumn get relatedRecordId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
