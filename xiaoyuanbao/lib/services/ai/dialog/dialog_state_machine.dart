import '../../../core/constants/app_enums.dart';

class DialogStateTransition {
  final DialogState newState;
  final bool shouldExecuteAction;
  final List<String>? additionalMissingParams;
  final Map<String, dynamic>? mergedEntities;
  final String? systemMessage;

  DialogStateTransition({
    required this.newState,
    this.shouldExecuteAction = false,
    this.additionalMissingParams,
    this.mergedEntities,
    this.systemMessage,
  });
}

class DialogStateMachine {
  DialogState _currentState = DialogState.idle;
  AiIntent? _pendingIntent;
  Map<String, dynamic> _collectedEntities = {};
  List<String> _missingParams = [];
  DateTime? _lastInteractionTime;

  DialogState get currentState => _currentState;
  AiIntent? get pendingIntent => _pendingIntent;
  Map<String, dynamic> get collectedEntities => Map.unmodifiable(_collectedEntities);
  List<String> get missingParams => List.unmodifiable(_missingParams);
  DateTime? get lastInteractionTime => _lastInteractionTime;

  DialogStateTransition processInput(
    String input,
    AiIntent intent,
    Map<String, dynamic> entities,
  ) {
    _lastInteractionTime = DateTime.now();

    if (_pendingIntent != null && intent != AiIntent.unknown && intent != _pendingIntent) {
      reset();
    }

    return switch (_currentState) {
      DialogState.idle => _handleIdleState(input, intent, entities),
      DialogState.waitingTime => _handleWaitingTimeState(input, intent, entities),
      DialogState.waitingAmount => _handleWaitingAmountState(input, intent, entities),
      DialogState.waitingConfirm => _handleWaitingConfirmState(input, intent, entities),
      DialogState.waitingClarify => _handleWaitingClarifyState(input, intent, entities),
    };
  }

  void startPending(
    AiIntent intent,
    List<String> missingParams,
    Map<String, dynamic> collected,
  ) {
    _pendingIntent = intent;
    _collectedEntities = Map.from(collected);
    _missingParams = List.from(missingParams);
    _lastInteractionTime = DateTime.now();

    if (missingParams.contains('time') || missingParams.contains('dateTime')) {
      _currentState = DialogState.waitingTime;
    } else if (missingParams.contains('amount') || missingParams.contains('quantity')) {
      _currentState = DialogState.waitingAmount;
    } else if (missingParams.length == 1) {
      _currentState = DialogState.waitingClarify;
    } else {
      _currentState = DialogState.waitingClarify;
    }
  }

  bool isPending() {
    return _pendingIntent != null && _currentState != DialogState.idle;
  }

  void reset() {
    _currentState = DialogState.idle;
    _pendingIntent = null;
    _collectedEntities.clear();
    _missingParams.clear();
  }

  bool isExpired(Duration timeout) {
    if (_lastInteractionTime == null) return false;
    return DateTime.now().difference(_lastInteractionTime!) > timeout;
  }

  DialogStateTransition _handleIdleState(
    String input,
    AiIntent intent,
    Map<String, dynamic> entities,
  ) {
    if (intent == AiIntent.unknown) {
      return DialogStateTransition(
        newState: DialogState.idle,
        systemMessage: '抱歉，我不太理解你的意思，可以再说一遍吗？',
      );
    }

    final missing = _getMissingParams(intent, entities);

    if (missing.isEmpty) {
      return DialogStateTransition(
        newState: DialogState.idle,
        shouldExecuteAction: true,
        mergedEntities: Map.from(entities),
      );
    }

    _pendingIntent = intent;
    _collectedEntities = Map.from(entities);
    _missingParams = List.from(missing);

    DialogState nextState;
    String? message;

    if (missing.contains('time') || missing.contains('dateTime')) {
      nextState = DialogState.waitingTime;
      message = _getTimePrompt(intent);
    } else if (missing.contains('amount') || missing.contains('quantity')) {
      nextState = DialogState.waitingAmount;
      message = _getAmountPrompt(intent);
    } else {
      nextState = DialogState.waitingClarify;
      message = _getClarifyPrompt(intent, missing);
    }

    _currentState = nextState;

    return DialogStateTransition(
      newState: nextState,
      additionalMissingParams: missing,
      mergedEntities: Map.from(entities),
      systemMessage: message,
    );
  }

  DialogStateTransition _handleWaitingTimeState(
    String input,
    AiIntent intent,
    Map<String, dynamic> entities,
  ) {
    final merged = Map<String, dynamic>.from(_collectedEntities);
    entities.forEach((key, value) {
      merged[key] = value;
    });

    if (entities.containsKey('time') || entities.containsKey('dateTime')) {
      _collectedEntities = merged;
      _missingParams.remove('time');
      _missingParams.remove('dateTime');

      if (_missingParams.isEmpty) {
        final currentIntent = _pendingIntent!;
        reset();
        return DialogStateTransition(
          newState: DialogState.idle,
          shouldExecuteAction: true,
          mergedEntities: merged,
        );
      }

      if (_missingParams.contains('amount') || _missingParams.contains('quantity')) {
        _currentState = DialogState.waitingAmount;
        return DialogStateTransition(
          newState: DialogState.waitingAmount,
          additionalMissingParams: List.from(_missingParams),
          mergedEntities: merged,
          systemMessage: _getAmountPrompt(_pendingIntent!),
        );
      }

      _currentState = DialogState.waitingClarify;
      return DialogStateTransition(
        newState: DialogState.waitingClarify,
        additionalMissingParams: List.from(_missingParams),
        mergedEntities: merged,
        systemMessage: _getClarifyPrompt(_pendingIntent!, _missingParams),
      );
    }

    return DialogStateTransition(
      newState: DialogState.waitingTime,
      systemMessage: _getTimePrompt(_pendingIntent!),
    );
  }

  DialogStateTransition _handleWaitingAmountState(
    String input,
    AiIntent intent,
    Map<String, dynamic> entities,
  ) {
    final merged = Map<String, dynamic>.from(_collectedEntities);
    entities.forEach((key, value) {
      merged[key] = value;
    });

    if (entities.containsKey('amount') || entities.containsKey('quantity')) {
      _collectedEntities = merged;
      _missingParams.remove('amount');
      _missingParams.remove('quantity');

      if (_missingParams.isEmpty) {
        final currentIntent = _pendingIntent!;
        reset();
        return DialogStateTransition(
          newState: DialogState.idle,
          shouldExecuteAction: true,
          mergedEntities: merged,
        );
      }

      if (_missingParams.contains('time') || _missingParams.contains('dateTime')) {
        _currentState = DialogState.waitingTime;
        return DialogStateTransition(
          newState: DialogState.waitingTime,
          additionalMissingParams: List.from(_missingParams),
          mergedEntities: merged,
          systemMessage: _getTimePrompt(_pendingIntent!),
        );
      }

      _currentState = DialogState.waitingClarify;
      return DialogStateTransition(
        newState: DialogState.waitingClarify,
        additionalMissingParams: List.from(_missingParams),
        mergedEntities: merged,
        systemMessage: _getClarifyPrompt(_pendingIntent!, _missingParams),
      );
    }

    return DialogStateTransition(
      newState: DialogState.waitingAmount,
      systemMessage: _getAmountPrompt(_pendingIntent!),
    );
  }

  DialogStateTransition _handleWaitingConfirmState(
    String input,
    AiIntent intent,
    Map<String, dynamic> entities,
  ) {
    final isConfirmed = _isConfirmInput(input);
    final isDenied = _isDenyInput(input);

    if (isConfirmed) {
      final merged = Map<String, dynamic>.from(_collectedEntities);
      final currentIntent = _pendingIntent!;
      reset();
      return DialogStateTransition(
        newState: DialogState.idle,
        shouldExecuteAction: true,
        mergedEntities: merged,
      );
    }

    if (isDenied) {
      reset();
      return DialogStateTransition(
        newState: DialogState.idle,
        systemMessage: '好的，已取消操作。',
      );
    }

    return DialogStateTransition(
      newState: DialogState.waitingConfirm,
      systemMessage: '请确认是否继续？（是/否）',
    );
  }

  DialogStateTransition _handleWaitingClarifyState(
    String input,
    AiIntent intent,
    Map<String, dynamic> entities,
  ) {
    final merged = Map<String, dynamic>.from(_collectedEntities);
    entities.forEach((key, value) {
      merged[key] = value;
    });

    final remainingMissing = <String>[];
    for (final param in _missingParams) {
      if (!merged.containsKey(param)) {
        remainingMissing.add(param);
      }
    }

    _collectedEntities = merged;
    _missingParams = remainingMissing;

    if (_missingParams.isEmpty) {
      final currentIntent = _pendingIntent!;
      reset();
      return DialogStateTransition(
        newState: DialogState.idle,
        shouldExecuteAction: true,
        mergedEntities: merged,
      );
    }

    return DialogStateTransition(
      newState: DialogState.waitingClarify,
      additionalMissingParams: List.from(_missingParams),
      mergedEntities: merged,
      systemMessage: _getClarifyPrompt(_pendingIntent!, _missingParams),
    );
  }

  List<String> _getMissingParams(AiIntent intent, Map<String, dynamic> entities) {
    final missing = <String>[];

    switch (intent) {
      case AiIntent.recordFeeding:
      case AiIntent.recordBreastfeeding:
      case AiIntent.recordSolidFood:
        if (!entities.containsKey('amount') && !entities.containsKey('quantity')) {
          missing.add('amount');
        }
        if (!entities.containsKey('time') && !entities.containsKey('dateTime')) {
          missing.add('time');
        }
        break;
      case AiIntent.recordSleepStart:
      case AiIntent.recordSleepEnd:
        if (!entities.containsKey('time') && !entities.containsKey('dateTime')) {
          missing.add('time');
        }
        break;
      case AiIntent.recordDiaper:
        if (!entities.containsKey('diaperType')) {
          missing.add('diaperType');
        }
        if (!entities.containsKey('time') && !entities.containsKey('dateTime')) {
          missing.add('time');
        }
        break;
      case AiIntent.recordTemperature:
        if (!entities.containsKey('temperature') && !entities.containsKey('amount')) {
          missing.add('amount');
        }
        if (!entities.containsKey('time') && !entities.containsKey('dateTime')) {
          missing.add('time');
        }
        break;
      case AiIntent.recordMedication:
        if (!entities.containsKey('medicineName')) {
          missing.add('medicineName');
        }
        if (!entities.containsKey('amount') && !entities.containsKey('quantity')) {
          missing.add('amount');
        }
        if (!entities.containsKey('time') && !entities.containsKey('dateTime')) {
          missing.add('time');
        }
        break;
      case AiIntent.recordMilestone:
        if (!entities.containsKey('milestone')) {
          missing.add('milestone');
        }
        break;
      case AiIntent.recordVaccine:
        if (!entities.containsKey('vaccineName')) {
          missing.add('vaccineName');
        }
        break;
      case AiIntent.recordGrowth:
        if (!entities.containsKey('height') && !entities.containsKey('weight')) {
          missing.add('amount');
        }
        break;
      case AiIntent.recordStool:
        if (!entities.containsKey('stoolColor')) {
          missing.add('stoolColor');
        }
        break;
      case AiIntent.recordDiary:
        if (!entities.containsKey('content')) {
          missing.add('content');
        }
        break;
      default:
        break;
    }

    return missing;
  }

  String _getTimePrompt(AiIntent? intent) {
    if (intent == null) return '请问是什么时间呢？';

    return switch (intent) {
      AiIntent.recordFeeding ||
      AiIntent.recordBreastfeeding ||
      AiIntent.recordSolidFood =>
        '请问是什么时候喂的呢？',
      AiIntent.recordSleepStart || AiIntent.recordSleepEnd => '请问是什么时候呢？',
      AiIntent.recordDiaper => '请问是什么时候换的尿布呢？',
      AiIntent.recordTemperature => '请问是什么时候量的体温呢？',
      AiIntent.recordMedication => '请问是什么时候吃的药呢？',
      _ => '请问是什么时间呢？',
    };
  }

  String _getAmountPrompt(AiIntent? intent) {
    if (intent == null) return '请问数量是多少呢？';

    return switch (intent) {
      AiIntent.recordFeeding || AiIntent.recordSolidFood => '请问吃了多少呢？',
      AiIntent.recordBreastfeeding => '请问喂了多长时间呢？',
      AiIntent.recordTemperature => '请问体温是多少度呢？',
      AiIntent.recordMedication => '请问吃了多少剂量呢？',
      AiIntent.recordGrowth => '请问身高体重是多少呢？',
      _ => '请问数量是多少呢？',
    };
  }

  String _getClarifyPrompt(AiIntent? intent, List<String> missingParams) {
    if (missingParams.isEmpty) return '请补充一下信息吧。';

    final paramLabels = <String, String>{
      'time': '时间',
      'dateTime': '时间',
      'amount': '数量',
      'quantity': '数量',
      'diaperType': '尿布类型',
      'medicineName': '药品名称',
      'milestone': '里程碑内容',
      'vaccineName': '疫苗名称',
      'stoolColor': '大便颜色',
      'content': '内容',
    };

    final labels = missingParams
        .map((p) => paramLabels[p] ?? p)
        .toList();

    if (labels.length == 1) {
      return '请问${labels.first}是什么呢？';
    }

    return '还需要补充以下信息：${labels.join('、')}，请告诉我吧。';
  }

  bool _isConfirmInput(String input) {
    final lower = input.toLowerCase().trim();
    return lower == '是' ||
        lower == '好的' ||
        lower == '好' ||
        lower == '确认' ||
        lower == '确定' ||
        lower == '对' ||
        lower == '没错' ||
        lower == '嗯' ||
        lower == '可以' ||
        lower == '行' ||
        lower.contains('确认') ||
        lower.contains('确定');
  }

  bool _isDenyInput(String input) {
    final lower = input.toLowerCase().trim();
    return lower == '否' ||
        lower == '不' ||
        lower == '不是' ||
        lower == '取消' ||
        lower == '算了' ||
        lower == '不用' ||
        lower == '不需要' ||
        lower == '不对' ||
        lower == '错了' ||
        lower.contains('取消');
  }
}
