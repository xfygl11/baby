import 'dart:math';
import '../../data/drift/daos/baby_repository.dart';
import '../../data/drift/daos/milestone_repository.dart';
import '../../data/drift/daos/quote_repository.dart';
import '../../data/drift/daos/diary_repository.dart';
import '../../core/utils/date_time_utils.dart';

class GeneratedStory {
  final String title;
  final String content;
  final String theme;
  final List<String> moralLessons;

  GeneratedStory({
    required this.title,
    required this.content,
    required this.theme,
    required this.moralLessons,
  });
}

class GeneratedLetter {
  final String title;
  final String content;
  final String occasion;

  GeneratedLetter({
    required this.title,
    required this.content,
    required this.occasion,
  });
}

class StoryGeneratorService {
  final BabyRepository _babyRepo;
  final MilestoneRepository _milestoneRepo;
  final QuoteRepository _quoteRepo;
  final DiaryRepository _diaryRepo;
  final Random _random = Random();

  StoryGeneratorService(
    this._babyRepo,
    this._milestoneRepo,
    this._quoteRepo,
    this._diaryRepo,
  );

  Future<GeneratedStory> generateBedtimeStory({
    required String babyId,
    required String theme,
    String? customHint,
  }) async {
    final baby = await _babyRepo.getBabyById(babyId);
    final name = baby?.name ?? '萱萱';
    final nickname = '萱萱';

    final ageResult = baby != null
        ? DateTimeUtils.calculateAge(baby.birthDate)
        : null;
    final ageLabel = ageResult != null
        ? '${ageResult.years}岁${ageResult.months}个月'
        : '';

    final milestones = await _milestoneRepo.getAchievedMilestones(babyId);
    final recentMilestones = milestones.take(3).map((m) => m.name).toList();

    final quotes = await _quoteRepo.getAll(babyId);
    final recentQuotes = quotes.take(2).map((q) => q.content).toList();

    final template = _getStoryTemplate(theme);
    final storyContent = _fillTemplate(
      template.content,
      name: name,
      nickname: nickname,
      ageLabel: ageLabel,
      milestone: recentMilestones.isNotEmpty ? recentMilestones.first : '学会了新本领',
      quote: recentQuotes.isNotEmpty ? recentQuotes.first : '今天真开心',
      hint: customHint ?? '',
    );

    return GeneratedStory(
      title: _fillTitle(template.title, name: name, theme: theme),
      content: storyContent,
      theme: theme,
      moralLessons: template.moralLessons,
    );
  }

  Future<GeneratedLetter> generateGrowthLetter({
    required String babyId,
    required String occasion,
    String? customHint,
  }) async {
    final baby = await _babyRepo.getBabyById(babyId);
    final name = baby?.name ?? '萱萱';

    final ageResult = baby != null
        ? DateTimeUtils.calculateAge(baby.birthDate)
        : null;
    final ageLabel = ageResult != null
        ? '${ageResult.years}岁${ageResult.months}个月'
        : '';

    final milestones = await _milestoneRepo.getAchievedMilestones(babyId);
    final milestoneNames = milestones.take(5).map((m) => m.name).toList();

    final diaries = await _diaryRepo.getDiariesByBabyId(babyId);
    final recentDiary = diaries.isNotEmpty ? diaries.first.content : '';

    final template = _getLetterTemplate(occasion);
    final content = _fillTemplate(
      template.content,
      name: name,
      ageLabel: ageLabel,
      milestones: milestoneNames.join('、'),
      diary: recentDiary.length > 60 ? '${recentDiary.substring(0, 60)}…' : recentDiary,
      hint: customHint ?? '',
    );

    return GeneratedLetter(
      title: _fillTitle(template.title, name: name, occasion: occasion),
      content: content,
      occasion: occasion,
    );
  }

  List<String> getStoryThemes() {
    return [
      '小兔子冒险',
      '星星的秘密',
      '海底世界',
      '森林音乐会',
      '勇敢的小船',
      '云朵上的家',
      '彩虹精灵',
      '月亮船',
    ];
  }

  List<String> getLetterOccasions() {
    return [
      '生日祝福',
      '新年寄语',
      '成长寄语',
      '入学家书',
      '成年寄语',
      '日常温情',
    ];
  }

  _StoryTemplate _getStoryTemplate(String theme) {
    final templates = <String, _StoryTemplate>{
      '小兔子冒险': _StoryTemplate(
        title: '{name}和小兔子的奇妙冒险',
        content: '''夜幕降临，月亮婆婆挂上了树梢。

在一片柔软的草地里，住着一只叫{nickname}的小兔子。今天，{name}已经{ageLabel}啦，小兔子听说{name}最近{milestone}，特地跑来找{name}一起冒险。

"跟我来吧！"小兔子蹦蹦跳跳地说，"{name}今天说了一句好可爱的话：{quote}"

它们一起穿过开满星星花的小路，来到了一座闪闪发光的小山坡。山坡上有一棵会唱歌的树，树叶沙沙作响，像是在说：每一个勇敢迈出脚步的孩子，都是最棒的小冒险家。

小兔子掏出一根胡萝卜分给{name}，两个小伙伴坐在山坡上看流星。"你知道吗？"小兔子悄悄说，"每一颗流星，都是一个被好好爱着的孩子许下的愿望。"

{hint}

流星划过天际，{name}闭上眼睛许了个愿望。小兔子笑了，因为它知道，被这样温柔爱着的{name}，所有的愿望都会实现。

"晚安，小冒险家。"月亮婆婆轻声说，"明天还有更多奇妙等你发现呢。"''',
        moralLessons: ['勇敢探索世界', '珍惜友谊', '心怀美好愿望'],
      ),
      '星星的秘密': _StoryTemplate(
        title: '{name}和星星的秘密约定',
        content: '''在一个安静的夜晚，{name}抬头看着满天的星星。

{ageLabel}的{name}发现，有一颗最亮的星星一直在对着自己眨眼睛。那颗星星轻轻地说："{name}，我是你的守护星，我每天都看着你{milestone}呢。"

{name}开心极了，对着星星说："今天我说了{quote}，大家都笑了！"

星星温柔地笑了："那是因为你被很多很多人爱着呀。你知道吗？每一个被爱的孩子，心里都住着一颗会发光的小星星。"

{hint}

星星告诉{name}一个秘密：只要心地善良、勇敢善良，心里的星星就会越来越亮，照亮自己也照亮别人。

"明天晚上我还会来看你的。"星星说，"现在，闭上眼睛，让美梦带你飞到我身边来吧。"

{name}甜甜地笑了，慢慢进入了梦乡。在梦里，{name}变成了一颗小星星，和守护星一起，在银河里快乐地游来游去。''',
        moralLessons: ['心怀善良', '感受被爱', '勇敢发光'],
      ),
      '海底世界': _StoryTemplate(
        title: '{name}的海底奇妙之旅',
        content: '''大海深处，有一个五彩斑斓的珊瑚王国。

{ageLabel}的{name}变成了一条小小鱼，摇着尾巴游进了这个奇妙的世界。一条橙色的小丑鱼游过来说："你好呀{name}！听说你最近{milestone}，真厉害！"

它们一起在珊瑚丛中捉迷藏，{name}还学会了一句新话：{quote}，把海马叔叔都逗笑了。

{hint}

一只年纪很大的海龟爷爷游过来，慢慢地说："{name}，你知道吗？大海里最珍贵的不是珍珠，而是友谊和勇气。"

{name}点点头，和小丑鱼手拉手（虽然鱼没有手，但它们用鳍碰了碰），继续向深海探险。它们遇见了会发光的水母、会唱歌的鲸鱼，还有一个藏在贝壳里的音乐盒。

夜深了，{name}游回了海面，月光洒在海面上像碎银子一样。"明天再来玩吧！"小丑鱼挥手告别。

回到床上的{name}想，原来大海里藏着这么多好朋友呀。晚安，小冒险家。''',
        moralLessons: ['珍视友谊', '保持好奇', '勇敢探索'],
      ),
    };

    return templates[theme] ?? templates['小兔子冒险']!;
  }

  _LetterTemplate _getLetterTemplate(String occasion) {
    final templates = <String, _LetterTemplate>{
      '生日祝福': _LetterTemplate(
        title: '写给{name}的生日信',
        content: '''亲爱的{name}：

生日快乐！今天你已经{ageLabel}了。

看着你一天天长大，是爸爸妈妈最幸福的事。这一年来，你{milestones}，每一个小小的进步都让我们惊喜不已。

{diary}

{hint}

愿你永远被爱包围，永远眼中有光，心中有梦。无论未来走多远，家永远是你最温暖的港湾。

爱你的爸爸妈妈''',
      ),
      '新年寄语': _LetterTemplate(
        title: '写给{name}的新年信',
        content: '''亲爱的{name}：

新年好！新的一年开始了。

过去的一年，你{milestones}，{ageLabel}的你给我们带来了无数欢笑和感动。

{diary}

{hint}

新的一年，愿你健康快乐，勇敢善良。无论世界怎么变，我们的爱永远不变。

爱你的爸爸妈妈''',
      ),
      '成长寄语': _LetterTemplate(
        title: '写给{name}的成长寄语',
        content: '''亲爱的{name}：

时间过得真快，{ageLabel}的你已经长成一个小大人了。

这一路走来，你{milestones}，每一步都走得那么认真。

{diary}

{hint}

孩子，愿你永远保持好奇，永远勇敢向前。无论遇到什么，记得回头看看，我们一直在你身后。

永远爱你的爸爸妈妈''',
      ),
      '入学家书': _LetterTemplate(
        title: '写给{name}的入学家书',
        content: '''亲爱的{name}：

今天是你入学的好日子，{ageLabel}的你即将开始新的旅程。

回首这几年，你{milestones}，从咿呀学语到背起书包，时间真的会魔法。

{diary}

{hint}

学校是一个更大的世界，愿你保持善良，学会勇敢，交到好朋友，遇见好老师。无论成绩如何，你永远是我们最骄傲的{name}。

爱你的爸爸妈妈''',
      ),
      '成年寄语': _LetterTemplate(
        title: '写给{name}的成年寄语',
        content: '''亲爱的{name}：

恭喜你，成年了！18岁，是一个多么美好的年纪。

回首这18年，你{milestones}，从一个软软的小婴儿，长成了今天独立、善良、有担当的大人。

{diary}

{hint}

从今天起，你将掌舵自己的人生。愿你乘风破浪，也愿你被温柔以待；愿你追逐星辰，也愿你记得回家的路。

无论你飞得多高多远，我们的爱永远是你的底气。

永远爱你的爸爸妈妈''',
      ),
      '日常温情': _LetterTemplate(
        title: '写给{name}的悄悄话',
        content: '''亲爱的{name}：

今天你{ageLabel}了，想给你写几句悄悄话。

最近你{milestones}，每一个小瞬间都让我们心头暖暖的。

{diary}

{hint}

谢谢你选择做我们的孩子。愿你今天睡个好觉，做个美梦。

爱你的爸爸妈妈''',
      ),
    };

    return templates[occasion] ?? templates['日常温情']!;
  }

  String _fillTemplate(
    String template, {
    String name = '萱萱',
    String nickname = '萱萱',
    String ageLabel = '',
    String milestone = '学会了新本领',
    String quote = '今天真开心',
    String milestones = '成长了许多',
    String diary = '',
    String hint = '',
  }) {
    return template
        .replaceAll('{name}', name)
        .replaceAll('{nickname}', nickname)
        .replaceAll('{ageLabel}', ageLabel)
        .replaceAll('{milestone}', milestone)
        .replaceAll('{quote}', quote)
        .replaceAll('{milestones}', milestones)
        .replaceAll('{diary}', diary)
        .replaceAll('{hint}', hint);
  }

  String _fillTitle(String titleTemplate, {String name = '萱萱', String theme = '', String occasion = ''}) {
    return titleTemplate.replaceAll('{name}', name);
  }
}

class _StoryTemplate {
  final String title;
  final String content;
  final List<String> moralLessons;

  const _StoryTemplate({
    required this.title,
    required this.content,
    required this.moralLessons,
  });
}

class _LetterTemplate {
  final String title;
  final String content;

  const _LetterTemplate({
    required this.title,
    required this.content,
  });
}
