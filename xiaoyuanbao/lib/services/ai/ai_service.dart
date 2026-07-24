import 'package:flutter/foundation.dart';
import '../../core/constants/app_enums.dart';
import '../../data/drift/app_database.dart';
import '../../data/drift/daos/baby_repository.dart';
import '../../data/drift/daos/feeding_repository.dart';
import '../../data/drift/daos/sleep_repository.dart';
import '../../data/drift/daos/diaper_repository.dart';
import '../../data/drift/daos/temperature_repository.dart';
import '../../data/drift/daos/medication_repository.dart';
import '../../data/drift/daos/growth_repository.dart';
import '../../data/drift/daos/vaccine_repository.dart';
import '../../data/drift/daos/milestone_repository.dart';
import '../../data/drift/daos/diary_repository.dart';
import '../../data/drift/daos/ai_chat_repository.dart';
import 'intent/intent_classifier.dart';
import 'entity/entity_extractor.dart';
import 'action/action_executor.dart';
import 'reply/reply_generator.dart';
import 'dialog/dialog_state_machine.dart';
import 'dialog/context_memory.dart';

class AiService extends ChangeNotifier {
  final AppDatabase _db;
  late final IntentClassifier _intentClassifier;
  late final EntityExtractor _entityExtractor;
  late final ActionExecutor _actionExecutor;
  late final ReplyGenerator _replyGenerator;
  late final DialogStateMachine _dialogStateMachine;
  late final ContextMemory _contextMemory;
  late final BabyRepository _babyRepository;
  late final AiChatRepository _chatRepository;

  String? _currentBabyId;
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;
  
  AiService(this._db) {
    _init();
  }

  void _init() {
    _intentClassifier = IntentClassifier();
    _entityExtractor = EntityExtractor();
    _babyRepository = BabyRepository(_db);
    _chatRepository = AiChatRepository(_db);
    
    _actionExecutor = ActionExecutor(
      feedingRepository: FeedingRepository(_db),
      sleepRepository: SleepRepository(_db),
      diaperRepository: DiaperRepository(_db),
      temperatureRepository: TemperatureRepository(_db),
      medicationRepository: MedicationRepository(_db),
      growthRepository: GrowthRepository(_db),
      vaccineRepository: VaccineRepository(_db),
      milestoneRepository: MilestoneRepository(_db),
      diaryRepository: DiaryRepository(_db),
    );
    
    _replyGenerator = ReplyGenerator();
    _dialogStateMachine = DialogStateMachine();
    _contextMemory = ContextMemory();
  }

  Future<void> ensureBabyLoaded() async {
    if (_currentBabyId == null) {
      final baby = await _babyRepository.getActiveBaby();
      if (baby != null) {
        _currentBabyId = baby.id;
      }
    }
  }

  void setCurrentBaby(String babyId) {
    _currentBabyId = babyId;
  }

  Future<AiResponse> processMessage(String userInput) async {
    await ensureBabyLoaded();
    
    if (_currentBabyId == null) {
      return AiResponse(
        text: '还没有宝宝档案哦，先去创建一个吧～',
        intent: AiIntent.unknown,
        isError: true,
      );
    }

    _isProcessing = true;
    notifyListeners();

    try {
      final resolvedInput = _contextMemory.resolveReference(userInput) ?? userInput;
      
      final intent = _intentClassifier.classify(resolvedInput);
      final entities = _entityExtractor.extract(resolvedInput, intent);
      final transition = _dialogStateMachine.processInput(resolvedInput, intent, entities);

      String replyText;
      List<String>? createdRecordIds;
      bool success = true;
      Map<String, dynamic>? resultData;

      if (transition.shouldExecuteAction) {
        final result = await _actionExecutor.execute(
          _dialogStateMachine.pendingIntent ?? intent,
          transition.mergedEntities ?? entities,
          _currentBabyId!,
        );
        
        success = result.success;
        createdRecordIds = result.createdRecordIds;
        resultData = result.data;
        
        replyText = _replyGenerator.generateReply(
          _dialogStateMachine.pendingIntent ?? intent,
          transition.mergedEntities ?? entities,
          result,
          {'babyName': '小元宝'},
        );
      } else if (transition.systemMessage != null) {
        replyText = transition.systemMessage!;
      } else {
        final result = await _actionExecutor.execute(
          intent,
          entities,
          _currentBabyId!,
        );
        
        success = result.success;
        createdRecordIds = result.createdRecordIds;
        resultData = result.data;
        
        replyText = _replyGenerator.generateReply(
          intent,
          entities,
          result,
          {'babyName': '小元宝'},
        );
      }

      final userMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 0,
        content: userInput,
        intent: intent,
        entities: entities,
        relatedRecordId: createdRecordIds?.first,
        timestamp: DateTime.now(),
      );
      _contextMemory.addMessage(userMsg);
      await _chatRepository.addMessage(
        babyId: _currentBabyId!,
        role: 0,
        content: userInput,
        intent: intent.name,
        entitiesJson: entities.toString(),
        relatedRecordIds: createdRecordIds?.join(','),
      );

      final aiMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        role: 1,
        content: replyText,
        intent: intent,
        entities: null,
        relatedRecordId: null,
        timestamp: DateTime.now(),
      );
      _contextMemory.addMessage(aiMsg);
      await _chatRepository.addMessage(
        babyId: _currentBabyId!,
        role: 1,
        content: replyText,
        intent: intent.name,
        messageType: success ? 'text' : 'error',
      );

      _isProcessing = false;
      notifyListeners();

      return AiResponse(
        text: replyText,
        intent: intent,
        isSuccess: success,
        createdRecordIds: createdRecordIds,
        data: resultData,
      );
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      
      final errorText = _replyGenerator.generateErrorReply(e.toString());
      
      await _chatRepository.addMessage(
        babyId: _currentBabyId!,
        role: 1,
        content: errorText,
        intent: AiIntent.unknown.name,
        messageType: 'error',
      );

      return AiResponse(
        text: errorText,
        intent: AiIntent.unknown,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<List<AiChatMessage>> getChatHistory() async {
    await ensureBabyLoaded();
    if (_currentBabyId == null) return [];
    return _chatRepository.getRecentMessages(_currentBabyId!, limit: 50);
  }

  Future<void> clearChatHistory() async {
    await ensureBabyLoaded();
    if (_currentBabyId == null) return;
    await _chatRepository.clearMessages(_currentBabyId!);
    _contextMemory.clear();
    notifyListeners();
  }

  String generateSuggestions() {
    final suggestions = [
      '喂了120ml奶粉',
      '宝宝睡着了',
      '今天打了乙肝疫苗',
      '宝宝会翻身了',
      '体重6.5公斤',
      '今天总结一下',
    ];
    return suggestions.join('、');
  }

  List<String> getQuickActions() {
    return [
      '📊 今日总结',
      '💉 疫苗提醒',
      '📈 生长曲线',
      '💡 育儿建议',
    ];
  }
}

class AiResponse {
  final String text;
  final AiIntent intent;
  final bool isSuccess;
  final bool isError;
  final List<String>? createdRecordIds;
  final Map<String, dynamic>? data;
  final String? errorMessage;

  AiResponse({
    required this.text,
    required this.intent,
    this.isSuccess = true,
    this.isError = false,
    this.createdRecordIds,
    this.data,
    this.errorMessage,
  });
}
