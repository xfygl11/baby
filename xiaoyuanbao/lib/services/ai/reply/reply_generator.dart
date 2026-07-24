import '../../../core/constants/app_enums.dart';
import '../action/action_executor.dart';

class ReplyGenerator {
  String generateReply(
    AiIntent intent,
    Map<String, dynamic> entities,
    ActionResult result,
    Map<String, dynamic> context,
  ) {
    if (!result.success) {
      return generateErrorReply(result.message);
    }

    final babyName = context['babyName'] as String? ?? '宝宝';
    final babyNickname = context['babyNickname'] as String? ?? '萱萱';

    switch (intent) {
      case AiIntent.recordFeeding:
      case AiIntent.recordBreastfeeding:
      case AiIntent.recordSolidFood:
        return _generateFeedingReply(intent, entities, result, babyName, babyNickname);
      case AiIntent.recordSleepStart:
        return _generateSleepStartReply(entities, result, babyName, babyNickname);
      case AiIntent.recordSleepEnd:
        return _generateSleepEndReply(entities, result, babyName, babyNickname);
      case AiIntent.recordDiaper:
      case AiIntent.recordStool:
        return _generateDiaperReply(intent, entities, result, babyName, babyNickname);
      case AiIntent.recordTemperature:
        return _generateTemperatureReply(entities, result, babyName, babyNickname);
      case AiIntent.recordMedication:
        return _generateMedicationReply(entities, result, babyName, babyNickname);
      case AiIntent.recordGrowth:
        return _generateGrowthReply(entities, result, babyName, babyNickname);
      case AiIntent.recordVaccine:
        return _generateVaccineReply(entities, result, babyName, babyNickname);
      case AiIntent.recordMilestone:
        return _generateMilestoneReply(entities, result, babyName, babyNickname);
      case AiIntent.recordDiary:
        return _generateDiaryReply(entities, result, babyName, babyNickname);
      case AiIntent.queryFeedingToday:
        return _generateQueryFeedingReply(result, babyName, babyNickname);
      case AiIntent.querySleepToday:
        return _generateQuerySleepReply(result, babyName, babyNickname);
      case AiIntent.queryNextVaccine:
        return _generateQueryNextVaccineReply(result, babyName, babyNickname);
      case AiIntent.queryGrowth:
        return _generateQueryGrowthReply(result, babyName, babyNickname);
      case AiIntent.dailySummary:
        return _generateDailySummaryReply(result, babyName, babyNickname);
      default:
        return '好的，已记录～';
    }
  }

  String generateFollowUp(AiIntent intent, List<String> missingParams) {
    final paramMessages = <String, String>{
      'amount': '喝奶量是多少呢？',
      'temperature': '体温是多少度呢？',
      'medicineName': '药品名称是什么呢？',
      'vaccineName': '疫苗名称是什么呢？',
      'milestoneName': '里程碑名称是什么呢？',
      'content': '日记内容是什么呢？',
      'weight': '体重是多少呢？',
      'height': '身高是多少呢？',
    };

    if (missingParams.isNotEmpty) {
      final firstParam = missingParams.first;
      final question = paramMessages[firstParam] ?? '还需要更多信息哦～';
      return '嗯嗯，$question 🤔';
    }

    return '我还需要确认一些信息哦～';
  }

  String generateErrorReply(String error) {
    final errorReplies = [
      '哎呀，出了点小问题：$error 😅',
      '嗯... 好像遇到了一点小麻烦：$error 🤔',
      '抱歉，操作失败了：$error 😔',
      '呜，没成功呢：$error 💫',
    ];
    return errorReplies[DateTime.now().millisecond % errorReplies.length];
  }

  String _generateFeedingReply(
    AiIntent intent,
    Map<String, dynamic> entities,
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final data = result.data;
    final amount = data?['amountMl'] as double?;
    final type = data?['type'] as int?;

    if (intent == AiIntent.recordBreastfeeding) {
      final side = data?['breastSide'] as int?;
      final sideText = side == 0 ? '左边' : side == 1 ? '右边' : '两边';
      final replies = [
        '好的～已记录母乳喂养（$sideText）啦 🍼 $babyNickname棒棒哒！',
        '收到！母乳时间到！已记录好啦 🍼 $babyName吃得开心吗？',
        '嗯嗯，已记录母乳喂养～ 🍼 妈妈辛苦啦！',
      ];
      return replies[DateTime.now().millisecond % replies.length];
    } else if (intent == AiIntent.recordSolidFood) {
      final foodName = data?['foodName'] as String? ?? '辅食';
      final replies = [
        '好的～已记录吃$foodName啦 🥣 $babyName吃得香不香呀？',
        '收到！已记录$foodName 🥄 $babyNickname棒棒哒！',
        '嗯嗯，辅食时间到！已记录好啦 🥣',
      ];
      return replies[DateTime.now().millisecond % replies.length];
    } else {
      if (amount != null) {
        final replies = [
          '好的～已记录喝奶 ${amount.toInt()}ml 啦 🍼',
          '收到！喝奶 $babyName喝了 ${amount.toInt()}ml 真棒 🍼',
          '嗯嗯，${amount.toInt()}ml 奶已记录～ 🍼 $babyNickname好好长哦！',
        ];
        return replies[DateTime.now().millisecond % replies.length];
      } else {
        return '好的～已记录喝奶啦 🍼';
      }
    }
  }

  String _generateSleepStartReply(
    Map<String, dynamic> entities,
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final replies = [
      '好的，已开始记录睡眠 😴 $babyName好好睡～',
      '收到！$babyNickname乖乖睡觉哦 😴 做个好梦～',
      '嗯嗯，睡眠计时开始啦 😴 睡饱饱长高高！',
    ];
    return replies[DateTime.now().millisecond % replies.length];
  }

  String _generateSleepEndReply(
    Map<String, dynamic> entities,
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final data = result.data;
    final durationMinutes = data?['durationMinutes'] as int? ?? 0;
    final totalMinutes = data?['totalDurationMinutes'] as int? ?? 0;

    final duration = _formatDuration(durationMinutes);
    final total = _formatDuration(totalMinutes);

    final replies = [
      '睡醒啦～本次睡了 $duration，今天总共睡了 $total ⏰',
      '$babyName睡醒啦！这次睡了 $duration 呢 😊 今天一共睡了 $total',
      '哇！$babyNickname睡了 $duration，精神满满 ✨ 今天累计 $total',
    ];
    return replies[DateTime.now().millisecond % replies.length];
  }

  String _generateDiaperReply(
    AiIntent intent,
    Map<String, dynamic> entities,
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final data = result.data;
    final type = data?['type'] as int?;
    final hasRash = data?['hasRash'] as bool? ?? false;

    if (intent == AiIntent.recordStool) {
      final replies = [
        '好的～已记录便便啦 💩 $babyName便便正常吗？',
        '收到！便便记录好了 💩',
        '嗯嗯，已记录～ 💩',
      ];
      return replies[DateTime.now().millisecond % replies.length];
    }

    if (hasRash) {
      return '好的，尿布已记录～ 👶 有红疹要注意护理哦，保持干爽很重要！';
    }

    final typeText = type == 0
        ? '嘘嘘'
        : type == 1
            ? '便便'
            : '混合';

    final replies = [
      '好的～已记录$typeText尿布啦 👶',
      '收到！尿布换好啦 👶 $babyName舒服了吧～',
      '嗯嗯，尿布已记录 👶 干干净净的！',
    ];
    return replies[DateTime.now().millisecond % replies.length];
  }

  String _generateTemperatureReply(
    Map<String, dynamic> entities,
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final data = result.data;
    final temperature = data?['temperature'] as double? ?? 0;
    final isFever = data?['isFever'] as bool? ?? false;

    if (isFever) {
      if (temperature >= 38.5) {
        return '🌡️ 体温 ${temperature.toStringAsFixed(1)}℃，发烧了哦～ 超过38.5℃建议及时就医，多喝水多休息，物理降温也很重要！';
      } else {
        return '🌡️ 体温 ${temperature.toStringAsFixed(1)}℃，有点低烧哦～ 记得物理降温，多喝水，密切观察～';
      }
    } else {
      final replies = [
        '🌡️ 体温 ${temperature.toStringAsFixed(1)}℃，体温正常，$babyName棒棒哒！',
        '好的～体温 ${temperature.toStringAsFixed(1)}℃，正常范围 👍',
        '嗯嗯，体温记录好了 🌡️ $babyNickname很健康！',
      ];
      return replies[DateTime.now().millisecond % replies.length];
    }
  }

  String _generateMedicationReply(
    Map<String, dynamic> entities,
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final data = result.data;
    final medicineName = data?['medicineName'] as String? ?? '药';
    final dosage = data?['dosage'] as double? ?? 0;
    final unit = data?['unit'] as String? ?? '';

    final replies = [
      '💊 已记录吃$medicineName啦～ 按时吃药，$babyName很快就会好起来的！',
      '好的～$medicineName $dosage$unit 已记录 💊 乖乖吃药哦！',
      '嗯嗯，用药记录好了 💊 $babyNickname勇敢！',
    ];
    return replies[DateTime.now().millisecond % replies.length];
  }

  String _generateGrowthReply(
    Map<String, dynamic> entities,
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final data = result.data;
    final weight = data?['weight'] as double?;
    final height = data?['height'] as double?;
    final headCircumference = data?['headCircumference'] as double?;

    final parts = <String>[];
    if (weight != null) parts.add('体重${weight}kg');
    if (height != null) parts.add('身高${height}cm');
    if (headCircumference != null) parts.add('头围${headCircumference}cm');

    final summary = parts.isNotEmpty ? parts.join('、') : '生长数据';

    final replies = [
      '📏 已记录$summary啦～ $babyName长得真好！',
      '好的～生长记录已保存 📏 $babyNickname棒棒哒！',
      '嗯嗯，记录好了 📈 继续健康成长哦！',
    ];
    return replies[DateTime.now().millisecond % replies.length];
  }

  String _generateVaccineReply(
    Map<String, dynamic> entities,
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final data = result.data;
    final vaccineName = data?['vaccineName'] as String? ?? '疫苗';
    final status = data?['status'] as int?;

    if (status == 0) {
      return '💉 已预约$vaccineName接种～ 到时记得按时接种哦！';
    }

    final replies = [
      '💉 已记录$vaccineName接种！$babyName勇敢！下次接种提醒已设置～',
      '好的～$vaccineName已记录 💉 $babyNickname真勇敢！',
      '嗯嗯，疫苗接种记录好了 💉 注意观察反应哦～',
    ];
    return replies[DateTime.now().millisecond % replies.length];
  }

  String _generateMilestoneReply(
    Map<String, dynamic> entities,
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final data = result.data;
    final milestoneName = data?['name'] as String? ?? '里程碑';

    final replies = [
      '🎉 太棒了！又一个里程碑：$milestoneName！$babyName真厉害！',
      '哇！$milestoneName达成！🎉 $babyNickname棒棒哒！',
      '🎊 恭喜！$milestoneName 又进步啦～ 继续加油哦！',
    ];
    return replies[DateTime.now().millisecond % replies.length];
  }

  String _generateDiaryReply(
    Map<String, dynamic> entities,
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final data = result.data;
    final title = data?['title'] as String?;

    if (title != null && title.isNotEmpty) {
      return '📝 日记「$title」已保存～ 记录$babyName的美好时光！';
    }

    final replies = [
      '📝 日记已保存～ 记录$babyName的每一天都很珍贵！',
      '好的～日记写好啦 📝 美好的回忆！',
      '嗯嗯，记录保存成功 📖 $babyNickname又多了一个小故事！',
    ];
    return replies[DateTime.now().millisecond % replies.length];
  }

  String _generateQueryFeedingReply(
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final data = result.data;
    final count = data?['count'] as int? ?? 0;
    final totalAmount = data?['totalAmount'] as double? ?? 0;
    final avgInterval = data?['avgIntervalMinutes'] as double? ?? 0;

    if (count == 0) {
      return '🍼 今天还没有喝奶记录哦～';
    }

    final intervalText = avgInterval > 0
        ? '，平均间隔 ${(avgInterval / 60).toStringAsFixed(1)} 小时'
        : '';

    return '🍼 今天$babyName喝了 $count 次奶，总共 ${totalAmount.toInt()}ml$intervalText';
  }

  String _generateQuerySleepReply(
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final data = result.data;
    final count = data?['count'] as int? ?? 0;
    final totalMinutes = data?['totalDurationMinutes'] as int? ?? 0;
    final napCount = data?['napCount'] as int? ?? 0;
    final nightCount = data?['nightCount'] as int? ?? 0;

    if (count == 0) {
      return '😴 今天还没有睡眠记录哦～';
    }

    final total = _formatDuration(totalMinutes);

    return '😴 今天$babyName睡了 $count 次，总共 $total（小睡 $napCount 次，夜间 $nightCount 次）';
  }

  String _generateQueryNextVaccineReply(
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final data = result.data;

    if (data == null) {
      return '💉 暂无待接种疫苗，$babyName疫苗都打完啦～';
    }

    final vaccineName = data['vaccineName'] as String? ?? '疫苗';
    final scheduledDateStr = data['scheduledDate'] as String?;
    final doseNumber = data['doseNumber'] as int? ?? 1;
    final totalDoses = data['totalDoses'] as int? ?? 1;

    if (scheduledDateStr != null) {
      final scheduledDate = DateTime.parse(scheduledDateStr);
      final now = DateTime.now();
      final diff = scheduledDate.difference(now).inDays;

      String dateText;
      if (diff <= 0) {
        dateText = '就是今天';
      } else if (diff == 1) {
        dateText = '明天';
      } else {
        dateText = '还有 $diff 天';
      }

      return '💉 下次接种：$vaccineName（第 $doseNumber/$totalDoses 剂），$dateText哦～';
    }

    return '💉 下次接种：$vaccineName（第 $doseNumber/$totalDoses 剂）';
  }

  String _generateQueryGrowthReply(
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final data = result.data;

    if (data == null) {
      return '📏 还没有生长记录哦～';
    }

    final latest = data['latest'] as Map<String, dynamic>?;
    if (latest == null) {
      return '📏 还没有生长记录哦～';
    }

    final weight = latest['weight'] as double?;
    final height = latest['height'] as double?;
    final headCircumference = latest['headCircumference'] as double?;
    final bmi = latest['bmi'] as double?;

    final parts = <String>[];
    if (weight != null) parts.add('体重 ${weight}kg');
    if (height != null) parts.add('身高 ${height}cm');
    if (headCircumference != null) parts.add('头围 ${headCircumference}cm');

    final summary = parts.isNotEmpty ? parts.join('、') : '暂无数据';

    return '📏 $babyName最新生长数据：$summary';
  }

  String _generateDailySummaryReply(
    ActionResult result,
    String babyName,
    String babyNickname,
  ) {
    final data = result.data;
    if (data == null || data.isEmpty) {
      return '📋 今天还没有记录哦～';
    }

    final parts = <String>[];

    final feeding = data['feeding'] as Map<String, dynamic>?;
    if (feeding != null) {
      final count = feeding['count'] as int? ?? 0;
      final totalAmount = feeding['totalAmount'] as double? ?? 0;
      if (count > 0) {
        parts.add('🍼 喂养 $count 次，共 ${totalAmount.toInt()}ml');
      }
    }

    final sleep = data['sleep'] as Map<String, dynamic>?;
    if (sleep != null) {
      final count = sleep['count'] as int? ?? 0;
      final totalMinutes = sleep['totalDurationMinutes'] as int? ?? 0;
      if (count > 0) {
        parts.add('😴 睡眠 $count 次，共 ${_formatDuration(totalMinutes)}');
      }
    }

    final diaper = data['diaper'] as Map<String, dynamic>?;
    if (diaper != null) {
      final count = diaper['count'] as int? ?? 0;
      if (count > 0) {
        parts.add('👶 尿布 $count 次');
      }
    }

    final temperature = data['temperature'] as Map<String, dynamic>?;
    if (temperature != null) {
      final count = temperature['count'] as int? ?? 0;
      final latest = temperature['latest'] as Map<String, dynamic>?;
      if (count > 0 && latest != null) {
        final temp = latest['temperature'] as double?;
        if (temp != null) {
          parts.add('🌡️ 体温 ${temp.toStringAsFixed(1)}℃');
        }
      }
    }

    final milestones = data['milestones'] as Map<String, dynamic>?;
    if (milestones != null) {
      final todayCount = milestones['todayCount'] as int? ?? 0;
      if (todayCount > 0) {
        parts.add('🎉 今天达成 $todayCount 个里程碑');
      }
    }

    if (parts.isEmpty) {
      return '📋 今天还没有记录哦～ 开始记录$babyName的美好一天吧！';
    }

    final greeting = _getDailyGreeting();
    return '$greeting\n📋 今日$babyName小结：\n${parts.join('\n')}\n\n$babyNickname今天也很棒哦！💖';
  }

  String _getDailyGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '🌙 夜深了';
    if (hour < 9) return '🌅 早上好';
    if (hour < 12) return '☀️ 上午好';
    if (hour < 14) return '🌞 中午好';
    if (hour < 18) return '🌤️ 下午好';
    if (hour < 22) return '🌆 晚上好';
    return '🌙 晚上好';
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes分钟';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours小时';
    }
    return '$hours小时$mins分钟';
  }
}
