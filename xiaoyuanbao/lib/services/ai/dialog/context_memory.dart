import 'package:uuid/uuid.dart';

import '../../../core/constants/app_enums.dart';

class ChatMessage {
  final String id;
  final int role;
  final String content;
  final AiIntent? intent;
  final Map<String, dynamic>? entities;
  final String? relatedRecordId;
  final DateTime timestamp;

  ChatMessage({
    String? id,
    required this.role,
    required this.content,
    this.intent,
    this.entities,
    this.relatedRecordId,
    DateTime? timestamp,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == 0;
  bool get isAi => role == 1;

  ChatMessage copyWith({
    String? id,
    int? role,
    String? content,
    AiIntent? intent,
    Map<String, dynamic>? entities,
    String? relatedRecordId,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      intent: intent ?? this.intent,
      entities: entities ?? this.entities,
      relatedRecordId: relatedRecordId ?? this.relatedRecordId,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class ContextMemory {
  static const int _maxMessages = 50;
  static const int _recentWindow = 5;

  final List<ChatMessage> _messages = [];
  final List<AiIntent> _sessionIntents = [];
  Map<String, dynamic>? _lastRecord;

  int get messageCount => _messages.length;
  List<AiIntent> get sessionIntents => List.unmodifiable(_sessionIntents);
  Map<String, dynamic>? get lastRecord => _lastRecord;

  void addMessage(ChatMessage message) {
    _messages.add(message);

    if (_messages.length > _maxMessages) {
      _messages.removeAt(0);
    }

    if (message.isUser && message.intent != null && message.intent != AiIntent.unknown) {
      _sessionIntents.add(message.intent!);
    }

    if (message.relatedRecordId != null && message.isAi) {
      _lastRecord = {
        'recordId': message.relatedRecordId,
        'intent': message.intent,
        'content': message.content,
        'timestamp': message.timestamp,
      };
    }
  }

  List<ChatMessage> getRecentMessages(int count) {
    if (count <= 0) return [];
    final actualCount = count.clamp(0, _messages.length);
    return _messages.sublist(_messages.length - actualCount);
  }

  List<ChatMessage> getMessagesByRole(int role) {
    return _messages.where((m) => m.role == role).toList();
  }

  ChatMessage? getLastUserMessage() {
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].isUser) {
        return _messages[i];
      }
    }
    return null;
  }

  ChatMessage? getLastAiMessage() {
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].isAi) {
        return _messages[i];
      }
    }
    return null;
  }

  ChatMessage? getLastMessage() {
    if (_messages.isEmpty) return null;
    return _messages.last;
  }

  List<ChatMessage> getImmediateContext() {
    return getRecentMessages(_recentWindow);
  }

  void clear() {
    _messages.clear();
    _sessionIntents.clear();
    _lastRecord = null;
  }

  String? resolveReference(String input) {
    final trimmed = input.trim();

    if (_isBabyReference(trimmed)) {
      return 'baby';
    }

    if (_isLastRecordReference(trimmed)) {
      if (_lastRecord != null) {
        return _lastRecord!['recordId'] as String?;
      }
      return null;
    }

    if (_isSameTypeReference(trimmed)) {
      return _findLastSameTypeRecord();
    }

    return null;
  }

  Map<String, dynamic>? getLastRecord() {
    return _lastRecord != null ? Map.unmodifiable(_lastRecord!) : null;
  }

  void setLastRecord(Map<String, dynamic> record) {
    _lastRecord = Map.from(record);
  }

  List<ChatMessage> getMessagesForIntent(AiIntent intent) {
    return _messages.where((m) => m.intent == intent).toList();
  }

  ChatMessage? findPreviousMessage(String id) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index > 0) {
      return _messages[index - 1];
    }
    return null;
  }

  ChatMessage? findNextMessage(String id) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index >= 0 && index < _messages.length - 1) {
      return _messages[index + 1];
    }
    return null;
  }

  bool _isBabyReference(String input) {
    const babyKeywords = ['宝宝', '她', '他', '小宝', '宝贝'];
    for (final keyword in babyKeywords) {
      if (input.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  bool _isLastRecordReference(String input) {
    const lastRecordKeywords = ['它', '那条', '刚才的', '刚的', '刚说的', '这个', '那个'];
    for (final keyword in lastRecordKeywords) {
      if (input.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  bool _isSameTypeReference(String input) {
    const sameTypeKeywords = ['上次', '上一次', '上回', '之前'];
    for (final keyword in sameTypeKeywords) {
      if (input.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  String? _findLastSameTypeRecord() {
    final lastUserMessage = getLastUserMessage();
    if (lastUserMessage?.intent == null) return null;

    final targetIntent = lastUserMessage!.intent!;

    for (int i = _messages.length - 1; i >= 0; i--) {
      final msg = _messages[i];
      if (msg.isAi && msg.intent == targetIntent && msg.relatedRecordId != null) {
        return msg.relatedRecordId;
      }
    }

    return null;
  }

  List<ChatMessage> getTodayMessages() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    return _messages.where((m) => m.timestamp.isAfter(todayStart)).toList();
  }

  String getDailySummary() {
    final todayMessages = getTodayMessages();
    final userMessages = todayMessages.where((m) => m.isUser).toList();

    if (userMessages.isEmpty) {
      return '今天还没有对话记录。';
    }

    final intentCounts = <AiIntent, int>{};
    for (final msg in userMessages) {
      if (msg.intent != null && msg.intent != AiIntent.unknown) {
        intentCounts[msg.intent!] = (intentCounts[msg.intent!] ?? 0) + 1;
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('今日对话总结：');
    buffer.writeln('共 ${userMessages.length} 轮对话');

    if (intentCounts.isNotEmpty) {
      buffer.writeln('主要意图：');
      final sortedEntries = intentCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sortedEntries.take(5)) {
        buffer.writeln('  ${entry.key.name}: ${entry.value}次');
      }
    }

    if (_lastRecord != null) {
      buffer.writeln('最近记录：${_lastRecord!['content']}');
    }

    return buffer.toString();
  }
}
