import '../../../core/constants/app_enums.dart';

class EntityExtractor {
  static final List<String> _weightUnits = ['kg', '公斤', '千克', 'g', '克'];
  static final List<String> _heightUnits = ['cm', '厘米', '公分'];
  static final List<String> _headCircumferenceUnits = ['cm', '厘米', '公分'];
  static final List<String> _milkVolumeUnits = ['ml', '毫升'];
  static final List<String> _temperatureUnits = ['度', '℃', '°'];
  static final List<String> _durationMinuteUnits = ['分钟', '分'];
  static final List<String> _durationHourUnits = ['小时', '个小时', '钟头'];

  static final List<String> _vaccineNames = [
    '乙肝', '卡介苗', '脊灰', '百白破', '麻腮风', '乙脑',
    '流脑', '甲肝', '肺炎', '13价肺炎', '五联', '轮状',
    '手足口', 'EV71', '流感', '水痘', 'Hib', 'hib',
    '肺炎球菌', 'HPV', '狂犬疫苗', '破伤风',
  ];

  static final List<String> _medicineNames = [
    '布洛芬', '对乙酰氨基酚', '泰诺林', '美林', '维生素D',
    '维生素', '钙片', '钙', '益生菌', '妈咪爱',
    '蒙脱石散', '退烧药', '感冒药', '止咳药', '消炎药',
    '抗生素', '头孢', '阿莫西林',
  ];

  static final List<String> _milestoneTypes = [
    '翻身', '坐', '爬', '站', '走', '跑', '说话',
    '叫爸妈', '叫爸爸', '叫妈妈', '笑', '抬头', '抓握',
    '翻身', '会坐', '会爬', '会站', '会走', '会跑',
    '第一颗牙', '长牙', '会叫', '会说话',
  ];

  Map<String, dynamic> extract(String input, AiIntent intent) {
    final Map<String, dynamic> entities = {};

    final time = extractTime(input);
    if (time != null) {
      entities['time'] = time;
    }

    switch (intent) {
      case AiIntent.recordFeeding:
      case AiIntent.recordBreastfeeding:
        _extractFeedingEntities(input, entities);
        break;
      case AiIntent.recordSolidFood:
        _extractSolidFoodEntities(input, entities);
        break;
      case AiIntent.recordSleepStart:
      case AiIntent.recordSleepEnd:
        _extractSleepEntities(input, entities);
        break;
      case AiIntent.recordDiaper:
        _extractDiaperEntities(input, entities);
        break;
      case AiIntent.recordTemperature:
        _extractTemperatureEntities(input, entities);
        break;
      case AiIntent.recordMedication:
        _extractMedicationEntities(input, entities);
        break;
      case AiIntent.recordGrowth:
        _extractGrowthEntities(input, entities);
        break;
      case AiIntent.recordVaccine:
        _extractVaccineEntities(input, entities);
        break;
      case AiIntent.recordMilestone:
        _extractMilestoneEntities(input, entities);
        break;
      case AiIntent.recordStool:
        _extractStoolEntities(input, entities);
        break;
      case AiIntent.recordExpense:
        _extractExpenseEntities(input, entities);
        break;
      case AiIntent.recordActivity:
        _extractActivityEntities(input, entities);
        break;
      default:
        break;
    }

    return entities;
  }

  DateTime? extractTime(String input) {
    final now = DateTime.now();
    final lowerInput = input.toLowerCase().trim();

    DateTime baseDate = DateTime(now.year, now.month, now.day);

    if (lowerInput.contains('前天')) {
      baseDate = baseDate.subtract(const Duration(days: 2));
    } else if (lowerInput.contains('昨天')) {
      baseDate = baseDate.subtract(const Duration(days: 1));
    } else if (lowerInput.contains('今天')) {
      baseDate = baseDate;
    } else if (lowerInput.contains('明天')) {
      baseDate = baseDate.add(const Duration(days: 1));
    } else if (lowerInput.contains('后天')) {
      baseDate = baseDate.add(const Duration(days: 2));
    }

    int? hour;
    int? minute;

    final morningMatch = RegExp(r'上午\s*(\d{1,2})(?:[点时](\d{1,2})?)?', caseSensitive: false).firstMatch(input);
    if (morningMatch != null) {
      hour = int.parse(morningMatch.group(1)!);
      minute = morningMatch.group(2) != null ? int.parse(morningMatch.group(2)!) : 0;
      if (hour >= 12) hour = hour - 12;
    }

    final afternoonMatch = RegExp(r'下午\s*(\d{1,2})(?:[点时](\d{1,2})?)?', caseSensitive: false).firstMatch(input);
    if (afternoonMatch != null) {
      hour = int.parse(afternoonMatch.group(1)!);
      minute = afternoonMatch.group(2) != null ? int.parse(afternoonMatch.group(2)!) : 0;
      if (hour < 12) hour = hour + 12;
    }

    final eveningMatch = RegExp(r'晚上\s*(\d{1,2})(?:[点时](\d{1,2})?)?', caseSensitive: false).firstMatch(input);
    if (eveningMatch != null) {
      hour = int.parse(eveningMatch.group(1)!);
      minute = eveningMatch.group(2) != null ? int.parse(eveningMatch.group(2)!) : 0;
      if (hour < 12) hour = hour + 12;
    }

    final noonMatch = RegExp(r'中午\s*(\d{1,2})(?:[点时](\d{1,2})?)?', caseSensitive: false).firstMatch(input);
    if (noonMatch != null) {
      hour = int.parse(noonMatch.group(1)!);
      minute = noonMatch.group(2) != null ? int.parse(noonMatch.group(2)!) : 0;
      if (hour < 10) hour = hour + 12;
    }

    if (hour == null) {
      final simpleTimeMatch = RegExp(r'(\d{1,2})[点时](\d{1,2})?', caseSensitive: false).firstMatch(input);
      if (simpleTimeMatch != null) {
        hour = int.parse(simpleTimeMatch.group(1)!);
        minute = simpleTimeMatch.group(2) != null ? int.parse(simpleTimeMatch.group(2)!) : 0;

        if (lowerInput.contains('早上') || lowerInput.contains('早晨')) {
          if (hour >= 12) hour = hour - 12;
        } else if (lowerInput.contains('下午') || lowerInput.contains('晚上')) {
          if (hour < 12) hour = hour + 12;
        }
      }
    }

    final halfPastMatch = RegExp(r'(\d{1,2})点半', caseSensitive: false).firstMatch(input);
    if (halfPastMatch != null) {
      hour = int.parse(halfPastMatch.group(1)!);
      minute = 30;
      if (lowerInput.contains('下午') || lowerInput.contains('晚上')) {
        if (hour < 12) hour = hour + 12;
      }
    }

    if (lowerInput.contains('刚才') || lowerInput.contains('刚刚')) {
      return now.subtract(const Duration(minutes: 10));
    }

    if (hour != null) {
      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hour.clamp(0, 23),
        (minute ?? 0).clamp(0, 59),
      );
    }

    if (lowerInput.contains('今天') ||
        lowerInput.contains('昨天') ||
        lowerInput.contains('前天') ||
        lowerInput.contains('明天')) {
      return DateTime(baseDate.year, baseDate.month, baseDate.day, now.hour, now.minute);
    }

    return null;
  }

  double? extractNumberWithUnit(String input, List<String> units) {
    for (final unit in units) {
      final escapedUnit = RegExp.escape(unit);
      final pattern = RegExp(r'(\d+\.?\d*)\s*' + escapedUnit, caseSensitive: false);
      final match = pattern.firstMatch(input);
      if (match != null) {
        final number = double.parse(match.group(1)!);
        return number;
      }

      final reversedPattern = RegExp(escapedUnit + r'\s*(\d+\.?\d*)', caseSensitive: false);
      final reversedMatch = reversedPattern.firstMatch(input);
      if (reversedMatch != null) {
        final number = double.parse(reversedMatch.group(1)!);
        return number;
      }
    }
    return null;
  }

  void _extractFeedingEntities(String input, Map<String, dynamic> entities) {
    final milkVolume = extractNumberWithUnit(input, _milkVolumeUnits);
    if (milkVolume != null) {
      entities['amountMl'] = milkVolume;
    }

    final durationMinutes = extractNumberWithUnit(input, _durationMinuteUnits);
    if (durationMinutes != null) {
      entities['durationMinutes'] = durationMinutes.toInt();
    }

    final durationHours = extractNumberWithUnit(input, _durationHourUnits);
    if (durationHours != null) {
      entities['durationMinutes'] = (durationHours * 60).toInt();
    }

    if (input.contains('左边') || input.contains('左侧') || input.contains('左')) {
      if (input.contains('右边') || input.contains('右侧') || input.contains('右')) {
        entities['breastSide'] = BreastSide.both;
      } else {
        entities['breastSide'] = BreastSide.left;
      }
    } else if (input.contains('右边') || input.contains('右侧') || input.contains('右')) {
      entities['breastSide'] = BreastSide.right;
    }

    if (input.contains('奶粉') || input.contains('配方奶')) {
      entities['feedingType'] = FeedingType.formula;
    } else if (input.contains('母乳') || input.contains('亲喂')) {
      entities['feedingType'] = FeedingType.breastMilk;
    } else if (input.contains('辅食') || input.contains('米糊') || input.contains('米粉')) {
      entities['feedingType'] = FeedingType.solidFood;
    }

    if (milkVolume != null && (entities['feedingType'] == null)) {
      entities['feedingType'] = FeedingType.formula;
    }

    if (input.contains('左边') || input.contains('右边') || input.contains('母乳') || input.contains('亲喂')) {
      entities['feedingType'] = FeedingType.breastMilk;
    }
  }

  void _extractSolidFoodEntities(String input, Map<String, dynamic> entities) {
    entities['feedingType'] = FeedingType.solidFood;

    final foods = ['米糊', '米粉', '粥', '面条', '蛋黄', '果泥', '菜泥', '南瓜泥', '苹果泥', '香蕉泥'];
    for (final food in foods) {
      if (input.contains(food)) {
        entities['foodName'] = food;
        break;
      }
    }

    final durationMinutes = extractNumberWithUnit(input, _durationMinuteUnits);
    if (durationMinutes != null) {
      entities['durationMinutes'] = durationMinutes.toInt();
    }
  }

  void _extractSleepEntities(String input, Map<String, dynamic> entities) {
    final durationMinutes = extractNumberWithUnit(input, _durationMinuteUnits);
    if (durationMinutes != null) {
      entities['durationMinutes'] = durationMinutes.toInt();
    }

    final durationHours = extractNumberWithUnit(input, _durationHourUnits);
    if (durationHours != null) {
      entities['durationMinutes'] = (durationHours * 60).toInt();
    }

    if (input.contains('午睡') || input.contains('午休') || input.contains('午觉')) {
      entities['sleepType'] = SleepType.nap;
    } else if (input.contains('晚上') || input.contains('夜里') || input.contains('夜间')) {
      entities['sleepType'] = SleepType.night;
    }

    final locations = {
      '小床': SleepLocation.crib,
      '婴儿床': SleepLocation.crib,
      '大床': SleepLocation.bed,
      '推车': SleepLocation.stroller,
      '婴儿车': SleepLocation.stroller,
      '安全座椅': SleepLocation.carSeat,
      '背带': SleepLocation.carrier,
      '怀里': SleepLocation.other,
    };

    for (final entry in locations.entries) {
      if (input.contains(entry.key)) {
        entities['sleepLocation'] = entry.value;
        break;
      }
    }
  }

  void _extractDiaperEntities(String input, Map<String, dynamic> entities) {
    bool hasWet = input.contains('尿') || input.contains('湿');
    bool hasDirty = input.contains('便便') || input.contains('臭臭') || input.contains('拉') || input.contains('大便');

    if (hasWet && hasDirty) {
      entities['diaperType'] = DiaperType.mixed;
    } else if (hasDirty) {
      entities['diaperType'] = DiaperType.dirty;
    } else if (hasWet) {
      entities['diaperType'] = DiaperType.wet;
    }

    if (input.contains('红屁股') || input.contains('红屁屁') || input.contains('尿布疹')) {
      entities['hasRash'] = true;
    }

    final colors = {
      '黄色': StoolColor.yellow,
      '金黄': StoolColor.yellow,
      '棕色': StoolColor.brown,
      '褐色': StoolColor.brown,
      '绿色': StoolColor.green,
      '墨绿': StoolColor.green,
      '黑色': StoolColor.black,
      '红色': StoolColor.red,
      '血丝': StoolColor.red,
      '白色': StoolColor.white,
      '灰白': StoolColor.gray,
      '灰色': StoolColor.gray,
    };

    for (final entry in colors.entries) {
      if (input.contains(entry.key)) {
        entities['stoolColor'] = entry.value;
        break;
      }
    }
  }

  void _extractTemperatureEntities(String input, Map<String, dynamic> entities) {
    final temp = extractNumberWithUnit(input, _temperatureUnits);
    if (temp != null) {
      entities['temperature'] = temp;
    } else {
      final tempPattern = RegExp(r'(\d{2}\.?\d*)', caseSensitive: false);
      final match = tempPattern.firstMatch(input);
      if (match != null) {
        final value = double.parse(match.group(1)!);
        if (value >= 35 && value <= 42) {
          entities['temperature'] = value;
        }
      }
    }

    final sites = {
      '腋下': TemperatureSite.armpit,
      '腋窝': TemperatureSite.armpit,
      '胳膊': TemperatureSite.armpit,
      '耳朵': TemperatureSite.ear,
      '耳温': TemperatureSite.ear,
      '额头': TemperatureSite.forehead,
      '额温': TemperatureSite.forehead,
      '肛门': TemperatureSite.rectal,
      '直肠': TemperatureSite.rectal,
      '口腔': TemperatureSite.oral,
      '嘴里': TemperatureSite.oral,
    };

    for (final entry in sites.entries) {
      if (input.contains(entry.key)) {
        entities['site'] = entry.value;
        break;
      }
    }
  }

  void _extractMedicationEntities(String input, Map<String, dynamic> entities) {
    for (final medicine in _medicineNames) {
      if (input.contains(medicine)) {
        entities['medicineName'] = medicine;
        break;
      }
    }

    final dosageMl = extractNumberWithUnit(input, _milkVolumeUnits);
    if (dosageMl != null) {
      entities['dosage'] = dosageMl;
      entities['dosageUnit'] = 'ml';
    }

    final dosageMg = extractNumberWithUnit(input, ['mg', '毫克']);
    if (dosageMg != null) {
      entities['dosage'] = dosageMg;
      entities['dosageUnit'] = 'mg';
    }

    final dropPattern = RegExp(r'(\d+)\s*滴', caseSensitive: false);
    final dropMatch = dropPattern.firstMatch(input);
    if (dropMatch != null) {
      entities['dosage'] = double.parse(dropMatch.group(1)!);
      entities['dosageUnit'] = 'drop';
    }

    final tabletPattern = RegExp(r'(\d+)\s*片', caseSensitive: false);
    final tabletMatch = tabletPattern.firstMatch(input);
    if (tabletMatch != null) {
      entities['dosage'] = double.parse(tabletMatch.group(1)!);
      entities['dosageUnit'] = 'tablet';
    }

    if (input.contains('发烧') || input.contains('退热') || input.contains('退烧')) {
      entities['reason'] = '发烧';
    } else if (input.contains('感冒')) {
      entities['reason'] = '感冒';
    } else if (input.contains('咳嗽')) {
      entities['reason'] = '咳嗽';
    } else if (input.contains('拉肚子') || input.contains('腹泻')) {
      entities['reason'] = '腹泻';
    }
  }

  void _extractGrowthEntities(String input, Map<String, dynamic> entities) {
    double? weightKg = extractNumberWithUnit(input, ['kg', '公斤', '千克']);
    if (weightKg != null) {
      entities['weight'] = weightKg;
    } else {
      final weightG = extractNumberWithUnit(input, ['g', '克']);
      if (weightG != null && weightG > 100) {
        entities['weight'] = weightG / 1000;
      }
    }

    final height = extractNumberWithUnit(input, _heightUnits);
    if (height != null) {
      entities['height'] = height;
    }

    final headPattern = RegExp(r'头围.*?(\d+\.?\d*)\s*(cm|厘米|公分)', caseSensitive: false);
    final headMatch = headPattern.firstMatch(input);
    if (headMatch != null) {
      entities['headCircumference'] = double.parse(headMatch.group(1)!);
    } else {
      final headPattern2 = RegExp(r'(\d+\.?\d*)\s*(cm|厘米|公分).*?头围', caseSensitive: false);
      final headMatch2 = headPattern2.firstMatch(input);
      if (headMatch2 != null) {
        entities['headCircumference'] = double.parse(headMatch2.group(1)!);
      }
    }
  }

  void _extractVaccineEntities(String input, Map<String, dynamic> entities) {
    for (final vaccine in _vaccineNames) {
      if (input.contains(vaccine)) {
        entities['vaccineName'] = vaccine;
        break;
      }
    }

    final dosePattern = RegExp(r'第(\d+)[针剂]', caseSensitive: false);
    final doseMatch = dosePattern.firstMatch(input);
    if (doseMatch != null) {
      entities['doseNumber'] = int.parse(doseMatch.group(1)!);
    }

    if (input.contains('第一针') || input.contains('第1针')) {
      entities['doseNumber'] = 1;
    } else if (input.contains('第二针') || input.contains('第2针')) {
      entities['doseNumber'] = 2;
    } else if (input.contains('第三针') || input.contains('第3针')) {
      entities['doseNumber'] = 3;
    }

    if (input.contains('医院') || input.contains('社区') || input.contains('卫生院')) {
      final hospitalMatch = RegExp(r'在(.*?医院|.*?社区.*?|.*?卫生院)', caseSensitive: false).firstMatch(input);
      if (hospitalMatch != null) {
        entities['hospital'] = hospitalMatch.group(1);
      }
    }
  }

  void _extractMilestoneEntities(String input, Map<String, dynamic> entities) {
    for (final milestone in _milestoneTypes) {
      if (input.contains(milestone)) {
        entities['milestoneType'] = milestone;
        entities['title'] = '会$milestone了';
        break;
      }
    }

    if (input.contains('第一次')) {
      entities['isFirstTime'] = true;
    }

    if (input.contains('翻身')) {
      entities['category'] = MilestoneCategory.motor;
    } else if (input.contains('说话') || input.contains('叫')) {
      entities['category'] = MilestoneCategory.language;
    } else if (input.contains('坐') || input.contains('爬') || input.contains('站') || input.contains('走') || input.contains('跑')) {
      entities['category'] = MilestoneCategory.motor;
    } else if (input.contains('笑') || input.contains('抬头')) {
      entities['category'] = MilestoneCategory.motor;
    }
  }

  void _extractStoolEntities(String input, Map<String, dynamic> entities) {
    final colors = {
      '黄色': StoolColor.yellow,
      '金黄': StoolColor.yellow,
      '棕色': StoolColor.brown,
      '褐色': StoolColor.brown,
      '绿色': StoolColor.green,
      '墨绿': StoolColor.green,
      '黑色': StoolColor.black,
      '红色': StoolColor.red,
      '血丝': StoolColor.red,
      '白色': StoolColor.white,
      '灰白': StoolColor.gray,
      '灰色': StoolColor.gray,
    };

    for (final entry in colors.entries) {
      if (input.contains(entry.key)) {
        entities['stoolColor'] = entry.value;
        break;
      }
    }

    final countPattern = RegExp(r'(\d+)\s*次', caseSensitive: false);
    final countMatch = countPattern.firstMatch(input);
    if (countMatch != null) {
      entities['count'] = int.parse(countMatch.group(1)!);
    }
  }

  void _extractExpenseEntities(String input, Map<String, dynamic> entities) {
    final amount = extractNumberWithUnit(input, ['元', '块', '￥']);
    if (amount != null) {
      entities['amount'] = amount;
    } else {
      final moneyPattern = RegExp(r'￥\s*(\d+\.?\d*)', caseSensitive: false);
      final moneyMatch = moneyPattern.firstMatch(input);
      if (moneyMatch != null) {
        entities['amount'] = double.parse(moneyMatch.group(1)!);
      }
    }

    final categories = {
      '奶粉': '奶粉',
      '尿布': '尿布',
      '尿不湿': '尿布',
      '医院': '医疗',
      '看病': '医疗',
      '药': '医疗',
      '疫苗': '医疗',
      '学费': '教育',
      '兴趣班': '教育',
      '幼儿园': '教育',
      '玩具': '玩具',
      '衣服': '服装',
      '鞋子': '服装',
      '食品': '食品',
      '辅食': '食品',
    };

    for (final entry in categories.entries) {
      if (input.contains(entry.key)) {
        entities['category'] = entry.value;
        break;
      }
    }
  }

  void _extractActivityEntities(String input, Map<String, dynamic> entities) {
    final activities = {
      '抚触': '抚触',
      '游泳': '游泳',
      '趴趴': '趴趴时间',
      '趴着': '趴趴时间',
      '游戏': '游戏',
      '做游戏': '游戏',
      '绘本': '读绘本',
      '读书': '读绘本',
      '音乐': '听音乐',
      '听歌': '听音乐',
      '户外': '户外活动',
      '散步': '户外活动',
    };

    for (final entry in activities.entries) {
      if (input.contains(entry.key)) {
        entities['activityType'] = entry.value;
        break;
      }
    }

    final durationMinutes = extractNumberWithUnit(input, _durationMinuteUnits);
    if (durationMinutes != null) {
      entities['durationMinutes'] = durationMinutes.toInt();
    }

    final durationHours = extractNumberWithUnit(input, _durationHourUnits);
    if (durationHours != null) {
      entities['durationMinutes'] = (durationHours * 60).toInt();
    }
  }
}
