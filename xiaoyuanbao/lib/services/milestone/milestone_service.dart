import 'package:drift/drift.dart';
import '../../data/drift/daos/milestone_repository.dart';
import '../../data/drift/tables/milestone_records.dart';

class MilestoneCheckItem {
  final String id;
  final String name;
  final int category;
  final int expectedAgeMonths;
  bool isChecked;
  final String description;

  MilestoneCheckItem({
    required this.id,
    required this.name,
    required this.category,
    required this.expectedAgeMonths,
    this.isChecked = false,
    this.description = '',
  });
}

class _MilestoneTemplate {
  final String name;
  final int category;
  final int expectedAgeMonths;
  final String description;

  const _MilestoneTemplate({
    required this.name,
    required this.category,
    required this.expectedAgeMonths,
    this.description = '',
  });
}

class MilestoneService {
  final MilestoneRepository _repository;

  MilestoneService(this._repository);

  static const List<_MilestoneTemplate> _templates = [
    _MilestoneTemplate(
      name: '抬头45°',
      category: 0,
      expectedAgeMonths: 2,
      description: '俯卧时能抬头45度，头部能短暂保持稳定',
    ),
    _MilestoneTemplate(
      name: '抬头90°/俯卧抬胸',
      category: 0,
      expectedAgeMonths: 3,
      description: '俯卧时能抬头90度，胸部可离开床面',
    ),
    _MilestoneTemplate(
      name: '翻身（俯→仰）',
      category: 0,
      expectedAgeMonths: 4,
      description: '能从俯卧位翻身为仰卧位',
    ),
    _MilestoneTemplate(
      name: '独立坐',
      category: 0,
      expectedAgeMonths: 6,
      description: '不需要支撑能独立坐立片刻',
    ),
    _MilestoneTemplate(
      name: '翻身（仰→俯）',
      category: 0,
      expectedAgeMonths: 6,
      description: '能从仰卧位翻身为俯卧位',
    ),
    _MilestoneTemplate(
      name: '独坐稳',
      category: 0,
      expectedAgeMonths: 8,
      description: '能独立坐稳，身体前倾时能恢复平衡',
    ),
    _MilestoneTemplate(
      name: '会爬',
      category: 0,
      expectedAgeMonths: 8,
      description: '能用手和膝盖支撑身体爬行',
    ),
    _MilestoneTemplate(
      name: '扶站',
      category: 0,
      expectedAgeMonths: 9,
      description: '扶着家具或栏杆能站立',
    ),
    _MilestoneTemplate(
      name: '扶走',
      category: 0,
      expectedAgeMonths: 10,
      description: '扶着家具或栏杆能横走几步',
    ),
    _MilestoneTemplate(
      name: '独站',
      category: 0,
      expectedAgeMonths: 12,
      description: '不需要支撑能独自站立片刻',
    ),
    _MilestoneTemplate(
      name: '独走几步',
      category: 0,
      expectedAgeMonths: 12,
      description: '不需要搀扶能独立走几步',
    ),
    _MilestoneTemplate(
      name: '独走稳',
      category: 0,
      expectedAgeMonths: 15,
      description: '能独立行走，步态较稳',
    ),
    _MilestoneTemplate(
      name: '会跑',
      category: 0,
      expectedAgeMonths: 18,
      description: '能跑，动作还不太协调',
    ),
    _MilestoneTemplate(
      name: '扶栏上楼梯',
      category: 0,
      expectedAgeMonths: 18,
      description: '扶着栏杆能上楼梯',
    ),
    _MilestoneTemplate(
      name: '双脚跳',
      category: 0,
      expectedAgeMonths: 24,
      description: '能双脚同时离地跳起',
    ),
    _MilestoneTemplate(
      name: '跑稳',
      category: 0,
      expectedAgeMonths: 24,
      description: '跑步动作协调，能拐弯和停下',
    ),
    _MilestoneTemplate(
      name: '会微笑',
      category: 1,
      expectedAgeMonths: 1,
      description: '对人或声音能发出微笑',
    ),
    _MilestoneTemplate(
      name: '发出元音',
      category: 1,
      expectedAgeMonths: 2,
      description: '能发出a、o、e等元音',
    ),
    _MilestoneTemplate(
      name: '笑出声',
      category: 1,
      expectedAgeMonths: 3,
      description: '被逗引时能笑出声音',
    ),
    _MilestoneTemplate(
      name: '咿呀发声',
      category: 1,
      expectedAgeMonths: 3,
      description: '能咿咿呀呀发出连续的声音',
    ),
    _MilestoneTemplate(
      name: '叫名字有反应',
      category: 1,
      expectedAgeMonths: 6,
      description: '听到自己名字会转头或有反应',
    ),
    _MilestoneTemplate(
      name: '发辅音',
      category: 1,
      expectedAgeMonths: 6,
      description: '能发出b、m、d等辅音',
    ),
    _MilestoneTemplate(
      name: '会叫爸妈（无意识）',
      category: 1,
      expectedAgeMonths: 9,
      description: '无意识地发出"爸爸""妈妈"的音节',
    ),
    _MilestoneTemplate(
      name: '会叫爸妈（有意识）',
      category: 1,
      expectedAgeMonths: 12,
      description: '见到爸爸叫"爸爸"，见到妈妈叫"妈妈"',
    ),
    _MilestoneTemplate(
      name: '说2-3个字',
      category: 1,
      expectedAgeMonths: 12,
      description: '能说2-3个有意义的字',
    ),
    _MilestoneTemplate(
      name: '说10-20个字',
      category: 1,
      expectedAgeMonths: 18,
      description: '能说10-20个有意义的字词',
    ),
    _MilestoneTemplate(
      name: '指认身体部位',
      category: 1,
      expectedAgeMonths: 18,
      description: '能指出自己或他人的身体部位',
    ),
    _MilestoneTemplate(
      name: '说50+字',
      category: 1,
      expectedAgeMonths: 24,
      description: '能说50个以上的字词',
    ),
    _MilestoneTemplate(
      name: '简单句子',
      category: 1,
      expectedAgeMonths: 24,
      description: '能说2-3个字组成的简单句子',
    ),
    _MilestoneTemplate(
      name: '追视红球',
      category: 2,
      expectedAgeMonths: 1,
      description: '眼睛能跟随红球左右移动',
    ),
    _MilestoneTemplate(
      name: '伸手抓物',
      category: 2,
      expectedAgeMonths: 3,
      description: '能主动伸手去抓眼前的物品',
    ),
    _MilestoneTemplate(
      name: '吃手',
      category: 2,
      expectedAgeMonths: 3,
      description: '能把手放到嘴里吸吮',
    ),
    _MilestoneTemplate(
      name: '主动抓物',
      category: 2,
      expectedAgeMonths: 6,
      description: '能主动伸手抓住物品并握住',
    ),
    _MilestoneTemplate(
      name: '两手抓物',
      category: 2,
      expectedAgeMonths: 6,
      description: '两只手能同时抓住物品',
    ),
    _MilestoneTemplate(
      name: '会换手',
      category: 2,
      expectedAgeMonths: 9,
      description: '能将物品从一只手换到另一只手',
    ),
    _MilestoneTemplate(
      name: '再见拍手',
      category: 2,
      expectedAgeMonths: 9,
      description: '会做"再见"挥手和"欢迎"拍手的动作',
    ),
    _MilestoneTemplate(
      name: '用拇指食指捏物',
      category: 2,
      expectedAgeMonths: 12,
      description: '能用拇指和食指捏起小物品',
    ),
    _MilestoneTemplate(
      name: '指认物品',
      category: 2,
      expectedAgeMonths: 12,
      description: '能用手指指出常见的物品',
    ),
    _MilestoneTemplate(
      name: '垒积木2-3块',
      category: 2,
      expectedAgeMonths: 18,
      description: '能将2-3块积木垒起来',
    ),
    _MilestoneTemplate(
      name: '翻书',
      category: 2,
      expectedAgeMonths: 18,
      description: '能翻书，可能一次翻好几页',
    ),
    _MilestoneTemplate(
      name: '垒积木6-7块',
      category: 2,
      expectedAgeMonths: 24,
      description: '能将6-7块积木垒高',
    ),
    _MilestoneTemplate(
      name: '画圆圈',
      category: 2,
      expectedAgeMonths: 24,
      description: '握笔能画出近似圆形的线条',
    ),
    _MilestoneTemplate(
      name: '眼神对视',
      category: 3,
      expectedAgeMonths: 1,
      description: '能与照顾者有眼神对视',
    ),
    _MilestoneTemplate(
      name: '被逗会笑',
      category: 3,
      expectedAgeMonths: 2,
      description: '被人逗引时会露出笑容',
    ),
    _MilestoneTemplate(
      name: '认生',
      category: 3,
      expectedAgeMonths: 6,
      description: '见到陌生人会表现出紧张或哭闹',
    ),
    _MilestoneTemplate(
      name: '躲猫猫',
      category: 3,
      expectedAgeMonths: 6,
      description: '喜欢玩躲猫猫游戏，会寻找被藏起来的脸',
    ),
    _MilestoneTemplate(
      name: '认人',
      category: 3,
      expectedAgeMonths: 9,
      description: '能分辨熟悉的人和陌生人',
    ),
    _MilestoneTemplate(
      name: '怕陌生人',
      category: 3,
      expectedAgeMonths: 9,
      description: '见到陌生人会紧张、躲到父母身后',
    ),
    _MilestoneTemplate(
      name: '依恋父母',
      category: 3,
      expectedAgeMonths: 12,
      description: '对主要照顾者有明显的依恋',
    ),
    _MilestoneTemplate(
      name: '再见手势',
      category: 3,
      expectedAgeMonths: 12,
      description: '会做"再见"的挥手动作',
    ),
    _MilestoneTemplate(
      name: '分享兴趣',
      category: 3,
      expectedAgeMonths: 18,
      description: '会把自己感兴趣的东西指给别人看',
    ),
    _MilestoneTemplate(
      name: '假装游戏',
      category: 3,
      expectedAgeMonths: 18,
      description: '会玩假装游戏，如假装吃饭、打电话',
    ),
    _MilestoneTemplate(
      name: '和小朋友玩',
      category: 3,
      expectedAgeMonths: 24,
      description: '喜欢和其他小朋友一起玩',
    ),
    _MilestoneTemplate(
      name: '表达情绪',
      category: 3,
      expectedAgeMonths: 24,
      description: '能通过语言或动作表达自己的情绪',
    ),
    _MilestoneTemplate(
      name: '扶瓶',
      category: 4,
      expectedAgeMonths: 4,
      description: '能自己扶着奶瓶喝奶',
    ),
    _MilestoneTemplate(
      name: '添加辅食',
      category: 4,
      expectedAgeMonths: 6,
      description: '开始添加辅食，能接受泥糊状食物',
    ),
    _MilestoneTemplate(
      name: '会用勺',
      category: 4,
      expectedAgeMonths: 6,
      description: '对勺子感兴趣，会抓握勺子',
    ),
    _MilestoneTemplate(
      name: '自己拿饼干吃',
      category: 4,
      expectedAgeMonths: 9,
      description: '能自己拿着饼干或磨牙棒吃',
    ),
    _MilestoneTemplate(
      name: '自己用杯喝水',
      category: 4,
      expectedAgeMonths: 12,
      description: '能自己捧着杯子喝水（可能会洒）',
    ),
    _MilestoneTemplate(
      name: '自己吃饭',
      category: 4,
      expectedAgeMonths: 18,
      description: '能自己用手抓饭吃',
    ),
    _MilestoneTemplate(
      name: '用勺子吃饭',
      category: 4,
      expectedAgeMonths: 24,
      description: '能用勺子自己吃饭，较熟练',
    ),
  ];

  Future<void> generateMilestoneTemplates(String babyId) async {
    final existing = await _repository.getMilestonesByBabyId(babyId);
    final existingNames = existing.map((e) => e.name).toSet();

    final toInsert = <MilestoneRecordsCompanion>[];

    for (final template in _templates) {
      if (existingNames.contains(template.name)) {
        continue;
      }
      toInsert.add(
        MilestoneRecordsCompanion(
          name: Value(template.name),
          category: Value(template.category),
          expectedAgeMonths: Value(template.expectedAgeMonths),
          description: Value(template.description),
          isCustom: const Value(false),
          templateId: Value('template_${template.category}_${template.expectedAgeMonths}_${template.name}'),
        ),
      );
    }

    if (toInsert.isNotEmpty) {
      await _repository.batchInsertMilestones(babyId, toInsert);
    }
  }

  Future<List<MilestoneRecord>> getMilestonesByCategory(
    String babyId,
    int category,
  ) async {
    return _repository.getMilestonesByCategory(babyId, category);
  }

  Future<List<MilestoneRecord>> getMilestonesByMonth(
    String babyId,
    int ageMonths,
  ) async {
    final all = await _repository.getMilestonesByBabyId(babyId);
    return all
        .where((m) =>
            m.expectedAgeMonths != null &&
            (m.expectedAgeMonths! >= ageMonths - 1 &&
                m.expectedAgeMonths! <= ageMonths + 2))
        .toList()
      ..sort((a, b) =>
          (a.expectedAgeMonths ?? 0).compareTo(b.expectedAgeMonths ?? 0));
  }

  Future<List<MilestoneRecord>> getUpcomingMilestones(
    String babyId,
    int ageMonths,
  ) async {
    final all = await _repository.getMilestonesByBabyId(babyId);
    return all
        .where((m) =>
            m.achieveDate == null &&
            m.expectedAgeMonths != null &&
            m.expectedAgeMonths! >= ageMonths &&
            m.expectedAgeMonths! <= ageMonths + 2)
        .toList()
      ..sort((a, b) =>
          (a.expectedAgeMonths ?? 0).compareTo(b.expectedAgeMonths ?? 0));
  }

  Future<List<MilestoneRecord>> getAchievedMilestones(String babyId) async {
    return _repository.getAchievedMilestones(babyId);
  }

  Future<double> getMilestoneProgress(
    String babyId,
    int ageMonths,
  ) async {
    final all = await _repository.getMilestonesByBabyId(babyId);
    final relevant = all.where((m) {
      if (m.expectedAgeMonths == null) return false;
      return m.expectedAgeMonths! <= ageMonths;
    }).toList();

    if (relevant.isEmpty) return 0.0;

    final achieved = relevant.where((m) => m.achieveDate != null).length;
    return achieved / relevant.length;
  }

  Future<void> markMilestoneAchieved(
    String milestoneId,
    DateTime achieveDate, {
    String? description,
    String? imagePath,
  }) async {
    final data = MilestoneRecordsCompanion(
      achieveDate: Value(achieveDate),
      description: Value(description),
      imagePath: Value(imagePath),
    );
    await _repository.updateMilestone(milestoneId, data);
  }

  List<MilestoneCheckItem> getDevelopmentChecklist(int ageMonths) {
    return _templates
        .where((t) {
          if (ageMonths < 2) {
            return t.expectedAgeMonths <= 1;
          } else if (ageMonths < 3) {
            return t.expectedAgeMonths <= 2;
          } else if (ageMonths < 4) {
            return t.expectedAgeMonths <= 3;
          } else if (ageMonths < 6) {
            return t.expectedAgeMonths <= 4;
          } else if (ageMonths < 8) {
            return t.expectedAgeMonths <= 6;
          } else if (ageMonths < 9) {
            return t.expectedAgeMonths <= 8;
          } else if (ageMonths < 10) {
            return t.expectedAgeMonths <= 9;
          } else if (ageMonths < 12) {
            return t.expectedAgeMonths <= 10;
          } else if (ageMonths < 15) {
            return t.expectedAgeMonths <= 12;
          } else if (ageMonths < 18) {
            return t.expectedAgeMonths <= 15;
          } else if (ageMonths < 24) {
            return t.expectedAgeMonths <= 18;
          } else {
            return t.expectedAgeMonths <= 24;
          }
        })
        .map((t) => MilestoneCheckItem(
              id: 'check_${t.category}_${t.expectedAgeMonths}_${t.name}',
              name: t.name,
              category: t.category,
              expectedAgeMonths: t.expectedAgeMonths,
              description: t.description,
            ))
        .toList();
  }

  String getCategoryName(int category) {
    switch (category) {
      case 0:
        return '大运动';
      case 1:
        return '语言';
      case 2:
        return '认知';
      case 3:
        return '社交';
      case 4:
        return '喂养';
      default:
        return '其他';
    }
  }
}
