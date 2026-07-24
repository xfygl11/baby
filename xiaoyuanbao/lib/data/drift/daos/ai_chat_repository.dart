import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/ai_chat_messages.dart';

class AiChatRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  AiChatRepository(this._db);

  Future<String> addMessage({
    required String babyId,
    required int role,
    required String content,
    String? intent,
    String? entitiesJson,
    String? relatedRecordIds,
    String? messageType,
    bool hasConfirmed = false,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.aiChatMessages).insert(
          AiChatMessagesCompanion.insert(
            id: id,
            babyId: babyId,
            role: role,
            content: content,
            intent: Value(intent),
            entitiesJson: Value(entitiesJson),
            relatedRecordIds: Value(relatedRecordIds),
            messageType: Value(messageType ?? 'text'),
            hasConfirmed: Value(hasConfirmed),
          ),
        );
    return id;
  }

  Future<List<AiChatMessage>> getMessages(String babyId) async {
    return (_db.select(_db.aiChatMessages)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<List<AiChatMessage>> getRecentMessages(String babyId, int limit) async {
    return (_db.select(_db.aiChatMessages)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get()
        .then((list) => list.reversed.toList());
  }

  Future<void> clearMessages(String babyId) async {
    await (_db.update(_db.aiChatMessages)
          ..where((t) => t.babyId.equals(babyId))
          ..where((t) => t.isDeleted.equals(false)))
        .write(
          AiChatMessagesCompanion(
            isDeleted: const Value(true),
          ),
        );
  }

  Future<void> deleteMessage(String id) async {
    await (_db.update(_db.aiChatMessages)..where((t) => t.id.equals(id))).write(
          AiChatMessagesCompanion(
            isDeleted: const Value(true),
          ),
        );
  }
}
