import '../../../core/constants/app_enums.dart';

class IntentClassifier {
  static final Map<AiIntent, List<String>> _intentKeywords = {
    AiIntent.recordFeeding: [
      '喂奶', '吃奶', '喝奶', '吃了', '喝了', '奶', '奶粉', '母乳',
      'ml', '毫升', '喂了', '冲奶', '泡奶',
    ],
    AiIntent.recordBreastfeeding: [
      '左边', '右边', '左侧', '右侧', '母乳', '亲喂', '喂奶',
      '左奶', '右奶', '两侧', '双侧', '吃左边', '吃右边',
    ],
    AiIntent.recordSolidFood: [
      '辅食', '米糊', '米粉', '吃辅食', '加辅食',
      '粥', '面条', '蛋黄', '果泥', '菜泥',
    ],
    AiIntent.queryFeedingToday: [
      '今天吃了', '今天喂了', '今天奶量', '今天吃了多少',
      '今天喂了几次', '今天喝奶', '今天吃奶',
    ],
    AiIntent.recordSleepStart: [
      '睡着了', '睡了', '睡觉', '入睡', '午休', '午睡',
      '开始睡', '去睡觉', '睡觉了', '睡午觉', '睡了吗',
    ],
    AiIntent.recordSleepEnd: [
      '醒了', '醒来', '起床', '睡醒', '醒过来', '睡醒了',
      '起来了', '刚醒', '刚起床',
    ],
    AiIntent.querySleepToday: [
      '今天睡了', '今天睡眠', '今天睡了多久', '今天睡了几次',
      '今天睡了多长时间', '今天睡了多少',
    ],
    AiIntent.recordDiaper: [
      '尿布', '尿不湿', '换尿布', '尿了', '拉了', '便便', '臭臭',
      '换了', '换尿不湿', '尿片',
    ],
    AiIntent.recordTemperature: [
      '体温', '发烧', '温度', '度', '℃', '°',
      '量体温', '测体温', '发烧了', '发热',
    ],
    AiIntent.recordMedication: [
      '吃药', '用药', '退烧药', '布洛芬', '维生素',
      '喝药', '服药', '打了针', '打针', '点滴',
      '输液', '药膏', '涂药',
    ],
    AiIntent.recordGrowth: [
      '体重', '身高', '头围', 'cm', '公斤', 'kg', '厘米',
      '称体重', '量身高', '测头围',
    ],
    AiIntent.queryGrowth: [
      '长得怎么样', '发育正常吗', '生长曲线', '体重增长',
      '身高增长', '发育情况', '长了多少',
    ],
    AiIntent.predictGrowth: [
      '以后能长多高', '未来身高', '能长多高', '预测身高',
      '长大有多高', '成年身高',
    ],
    AiIntent.recordVaccine: [
      '疫苗', '预防针', '打针', '接种', '打了',
      '打疫苗', '打预防针', '接种疫苗',
    ],
    AiIntent.queryNextVaccine: [
      '下次疫苗', '下次打什么', '疫苗计划', '接下来打什么',
      '下次预防针', '还有哪些疫苗', '疫苗时间表',
    ],
    AiIntent.recordMilestone: [
      '第一次', '会翻身', '会坐', '会爬', '会走', '会说话',
      '里程碑', '长牙了', '会叫', '会笑', '抬头',
      '会站', '会跑', '第一颗牙',
    ],
    AiIntent.recordDiary: [
      '日记', '今天宝宝', '记录一下', '记一下', '写日记',
      '今天发生', '今天的事',
    ],
    AiIntent.recordStool: [
      '便便', '大便', '拉了', '拉屎', '臭臭', '排便',
      '绿色便便', '黑色便便', '拉肚子', '便秘',
    ],
    AiIntent.recordSkin: [
      '湿疹', '疹子', '痱子', '皮肤', '过敏', '起疹子',
      '脸上长', '身上长', '红点', '痘痘',
    ],
    AiIntent.recordAllergy: [
      '过敏', '过敏了', '起疹子', '过敏反应', '不能吃',
      '过敏原', '过敏体质',
    ],
    AiIntent.recordDoctorVisit: [
      '看病', '去医院', '看医生', '就诊', '体检',
      '挂号', '复诊', '检查',
    ],
    AiIntent.recordTeeth: [
      '长牙', '牙齿', '牙', '换牙', '掉牙', '乳牙',
      '长了一颗牙', '第一颗牙',
    ],
    AiIntent.recordVision: [
      '视力', '眼睛', '近视', '远视', '弱视',
      '测视力', '视力检查',
    ],
    AiIntent.recordSchool: [
      '上学', '学校', '班级', '老师', '入学',
      '一年级', '幼儿园', '班主任',
    ],
    AiIntent.recordExam: [
      '考试', '成绩', '分数', '分', '语文', '数学',
      '期中', '期末', '测验',
    ],
    AiIntent.recordAward: [
      '获奖', '奖', '一等奖', '二等奖', '荣誉',
      '奖状', '比赛', '冠军',
    ],
    AiIntent.recordInterestClass: [
      '兴趣班', '钢琴', '舞蹈', '画画', '围棋',
      '编程', '考级', '上课',
    ],
    AiIntent.recordPersonality: [
      '性格', '外向', '内向', '胆大', '谨慎',
      '敏感', '坚韧', '观察',
    ],
    AiIntent.recordEmotion: [
      '开心', '难过', '生气', '愤怒', '焦虑',
      '情绪', '发脾气', '哭了',
    ],
    AiIntent.recordQuote: [
      '语录', '记一句话', '宝宝说', '说的话',
      '童言', '童言无忌',
    ],
    AiIntent.recordActivity: [
      '互动', '做了', '玩了', '抚触', '游泳', '趴趴',
      '做游戏', '读绘本', '听音乐', '户外活动',
    ],
    AiIntent.recordExpense: [
      '费用', '花钱', '花了', '元', '块', '￥',
      '多少钱', '开销', '买了', '支出',
    ],
    AiIntent.dailySummary: [
      '总结', '回顾', '今天怎么样', '今天过得怎么样',
      '今天的总结', '每日总结', '今天一天',
    ],
    AiIntent.generateStory: [
      '讲故事', '故事', '睡前故事', '讲个故事',
      '听故事', '故事书',
    ],
    AiIntent.aiAdvice: [
      '怎么办', '建议', '育儿', '怎么', '如何',
      '有什么建议', '该怎么办', '怎么处理',
    ],
    AiIntent.showHelp: [
      '你能做什么', '帮助', '怎么用', '功能介绍',
      '使用说明', '有什么功能', '能干嘛', '可以做什么',
    ],
    AiIntent.chat: [
      '你好', '您好', '在吗', '嗨', '哈喽', 'hello',
      'hi', '谢谢', '感谢', '辛苦', '好累', '带娃好累',
      '开心', '难过', '郁闷', '烦',
    ],
  };

  static final Map<AiIntent, List<RegExp>> _intentPatterns = {
    AiIntent.recordFeeding: [
      RegExp(r'\d+\s*(ml|毫升).*奶', caseSensitive: false),
      RegExp(r'奶.*\d+\s*(ml|毫升)', caseSensitive: false),
    ],
    AiIntent.recordBreastfeeding: [
      RegExp(r'(左边|右边|左侧|右侧|左|右).*?(分钟|奶|喂)', caseSensitive: false),
      RegExp(r'(母乳|亲喂).*?(分钟|左边|右边)', caseSensitive: false),
    ],
    AiIntent.recordSolidFood: [
      RegExp(r'(辅食|米糊|米粉|粥|面条|蛋黄|果泥)', caseSensitive: false),
    ],
    AiIntent.recordTemperature: [
      RegExp(r'\d+\.?\d*\s*(度|℃|°)', caseSensitive: false),
      RegExp(r'(体温|发烧|发热).*\d+', caseSensitive: false),
    ],
    AiIntent.recordGrowth: [
      RegExp(r'\d+\.?\d*\s*(kg|公斤|千克)', caseSensitive: false),
      RegExp(r'\d+\.?\d*\s*(cm|厘米|公分)', caseSensitive: false),
    ],
    AiIntent.recordVaccine: [
      RegExp(r'(乙肝|卡介苗|脊灰|百白破|麻腮风|乙脑|流脑|甲肝|肺炎|五联|轮状|手足口|流感|水痘|hib)', caseSensitive: false),
    ],
    AiIntent.recordMilestone: [
      RegExp(r'会(翻身|坐|爬|站|走|跑|说话|叫|笑|抬头)', caseSensitive: false),
      RegExp(r'第一次', caseSensitive: false),
    ],
    AiIntent.recordExpense: [
      RegExp(r'\d+\.?\d*\s*(元|块|￥)', caseSensitive: false),
    ],
  };

  static final List<AiIntent> _priorityOrder = [
    AiIntent.recordTemperature,
    AiIntent.recordMedication,
    AiIntent.recordAllergy,
    AiIntent.recordDoctorVisit,
    AiIntent.recordVaccine,
    AiIntent.recordGrowth,
    AiIntent.recordBreastfeeding,
    AiIntent.recordSolidFood,
    AiIntent.recordFeeding,
    AiIntent.recordSleepStart,
    AiIntent.recordSleepEnd,
    AiIntent.recordDiaper,
    AiIntent.recordStool,
    AiIntent.recordSkin,
    AiIntent.recordTeeth,
    AiIntent.recordVision,
    AiIntent.recordMilestone,
    AiIntent.recordSchool,
    AiIntent.recordExam,
    AiIntent.recordAward,
    AiIntent.recordInterestClass,
    AiIntent.recordPersonality,
    AiIntent.recordEmotion,
    AiIntent.recordActivity,
    AiIntent.recordExpense,
    AiIntent.recordQuote,
    AiIntent.recordDiary,
    AiIntent.queryNextVaccine,
    AiIntent.queryFeedingToday,
    AiIntent.querySleepToday,
    AiIntent.queryGrowth,
    AiIntent.predictGrowth,
    AiIntent.dailySummary,
    AiIntent.generateStory,
    AiIntent.aiAdvice,
    AiIntent.showHelp,
    AiIntent.chat,
    AiIntent.unknown,
  ];

  AiIntent classify(String input) {
    final results = classifyMulti(input);
    return results.isNotEmpty ? results.first : AiIntent.unknown;
  }

  double confidence(String input, AiIntent intent) {
    final lowerInput = input.toLowerCase().trim();
    if (lowerInput.isEmpty) return 0.0;

    double score = 0.0;

    final keywords = _intentKeywords[intent];
    if (keywords != null) {
      int matchCount = 0;
      for (final keyword in keywords) {
        if (lowerInput.contains(keyword.toLowerCase())) {
          matchCount++;
          score += 0.15;
        }
      }
      if (matchCount > 0) {
        score += 0.2;
      }
    }

    final patterns = _intentPatterns[intent];
    if (patterns != null) {
      for (final pattern in patterns) {
        if (pattern.hasMatch(input)) {
          score += 0.3;
        }
      }
    }

    if (intent == AiIntent.recordDiary) {
      final otherIntents = AiIntent.values.where((i) =>
          i != AiIntent.recordDiary && i != AiIntent.chat && i != AiIntent.unknown);
      bool hasOtherIntent = false;
      for (final other in otherIntents) {
        if (confidence(input, other) > 0.3) {
          hasOtherIntent = true;
          break;
        }
      }
      if (!hasOtherIntent && input.length > 5) {
        score = 0.4;
      } else if (hasOtherIntent) {
        score = 0.1;
      }
    }

    if (intent == AiIntent.chat) {
      final otherIntents = AiIntent.values.where((i) =>
          i != AiIntent.chat && i != AiIntent.unknown);
      double maxOtherConfidence = 0.0;
      for (final other in otherIntents) {
        final conf = confidence(input, other);
        if (conf > maxOtherConfidence) {
          maxOtherConfidence = conf;
        }
      }
      if (maxOtherConfidence < 0.3 && score > 0) {
        score = 0.5;
      } else if (maxOtherConfidence >= 0.3) {
        score = 0.1;
      }
    }

    return score.clamp(0.0, 1.0);
  }

  List<AiIntent> classifyMulti(String input) {
    final lowerInput = input.toLowerCase().trim();
    if (lowerInput.isEmpty) {
      return [AiIntent.unknown];
    }

    final Map<AiIntent, double> scores = {};

    for (final intent in _priorityOrder) {
      if (intent == AiIntent.unknown) continue;
      final conf = confidence(input, intent);
      if (conf > 0.25) {
        scores[intent] = conf;
      }
    }

    if (scores.isEmpty) {
      if (_isLikelyDiary(input)) {
        return [AiIntent.recordDiary];
      }
      return [AiIntent.unknown];
    }

    final sortedEntries = scores.entries.toList()
      ..sort((a, b) {
        final cmp = b.value.compareTo(a.value);
        if (cmp != 0) return cmp;
        return _priorityOrder.indexOf(a.key).compareTo(_priorityOrder.indexOf(b.key));
      });

    return sortedEntries.map((e) => e.key).toList();
  }

  bool _isLikelyDiary(String input) {
    if (input.length < 5) return false;

    final chatKeywords = ['你好', '您好', '在吗', '嗨', '哈喽', '谢谢', '感谢'];
    for (final kw in chatKeywords) {
      if (input.toLowerCase().contains(kw)) {
        return false;
      }
    }

    final questionPatterns = [
      RegExp(r'^.*吗\??$'),
      RegExp(r'^怎么'),
      RegExp(r'^如何'),
      RegExp(r'^什么'),
    ];
    for (final pattern in questionPatterns) {
      if (pattern.hasMatch(input)) {
        return false;
      }
    }

    return true;
  }
}
