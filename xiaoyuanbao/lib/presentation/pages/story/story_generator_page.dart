import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/drift/app_database.dart';
import '../../../services/ai/story_generator_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class StoryGeneratorPage extends ConsumerStatefulWidget {
  const StoryGeneratorPage({super.key});

  @override
  ConsumerState<StoryGeneratorPage> createState() =>
      _StoryGeneratorPageState();
}

class _StoryGeneratorPageState extends ConsumerState<StoryGeneratorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final babyAsync = ref.watch(currentBabyProvider);

    return babyAsync.when(
      loading: () => Scaffold(
        backgroundColor: theme.stageBg,
        body: const LoadingWidget(message: '加载中...'),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: theme.stageBg,
        body: Center(
          child: Text(
            '加载失败: $error',
            style: TextStyle(color: theme.textPrimary),
          ),
        ),
      ),
      data: (baby) {
        if (baby == null) {
          return Scaffold(
            backgroundColor: theme.stageBg,
            appBar: AppBar(title: const Text('AI故事生成器')),
            body: const EmptyStateWidget(
              icon: Icons.child_care,
              title: '尚未添加宝宝',
              subtitle: '请先在个人中心添加宝宝信息',
            ),
          );
        }
        return Scaffold(
          backgroundColor: theme.stageBg,
          appBar: AppBar(
            title: const Text('AI故事生成器'),
            bottom: TabBar(
              controller: _tabController,
              labelColor: theme.stageAccent,
              unselectedLabelColor: theme.textSecondary,
              indicatorColor: theme.stageAccent,
              indicatorWeight: 3,
              labelStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: '🛏️ 睡前故事'),
                Tab(text: '💌 成长寄语'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              BedtimeStoryTab(baby: baby),
              GrowthLetterTab(baby: baby),
            ],
          ),
        );
      },
    );
  }
}

// ==================== 睡前故事 Tab ====================

class BedtimeStoryTab extends ConsumerStatefulWidget {
  final Baby baby;

  const BedtimeStoryTab({super.key, required this.baby});

  @override
  ConsumerState<BedtimeStoryTab> createState() => _BedtimeStoryTabState();
}

class _BedtimeStoryTabState extends ConsumerState<BedtimeStoryTab> {
  final TextEditingController _hintController = TextEditingController();
  late final List<String> _themes;
  int _selectedThemeIndex = 0;
  bool _isGenerating = false;
  GeneratedStory? _story;

  @override
  void initState() {
    super.initState();
    _themes =
        ref.read(storyGeneratorServiceProvider).getStoryThemes();
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);
    try {
      final service = ref.read(storyGeneratorServiceProvider);
      final story = await service.generateBedtimeStory(
        babyId: widget.baby.id,
        theme: _themes[_selectedThemeIndex],
        customHint: _hintController.text.trim().isEmpty
            ? null
            : _hintController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _story = story;
        _isGenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('生成失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(theme, '选择主题'),
          SizedBox(height: theme.spacingSm),
          _buildThemeChips(theme),
          SizedBox(height: theme.spacingMd),
          _buildHintField(theme),
          SizedBox(height: theme.spacingMd),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isGenerating ? null : _generate,
              icon: const Icon(Icons.auto_awesome, size: 20),
              label: Text(_story == null ? '生成故事' : '重新生成'),
            ),
          ),
          SizedBox(height: theme.spacingLg),
          if (_isGenerating)
            _buildLoading(theme)
          else if (_story != null)
            _buildStoryCard(theme)
          else
            _buildEmptyHint(theme, '选一个主题，为宝宝编织一个温柔的睡前故事吧'),
          SizedBox(height: theme.spacingXl),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(AppTheme theme, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.textSecondary,
      ),
    );
  }

  Widget _buildThemeChips(AppTheme theme) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _themes.length,
        separatorBuilder: (_, __) => SizedBox(width: theme.spacingSm),
        itemBuilder: (context, index) {
          final isSelected = _selectedThemeIndex == index;
          return Center(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedThemeIndex = index);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacingMd,
                  vertical: theme.spacingXs + 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.stageAccent
                      : theme.stageSurface,
                  borderRadius: BorderRadius.circular(theme.radiusPill),
                  border: Border.all(
                    color: isSelected
                        ? theme.stageAccent
                        : theme.textTertiary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _themes[index],
                  style: TextStyle(
                    color: isSelected
                        ? theme.onAccent
                        : theme.textSecondary,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHintField(AppTheme theme) {
    return TextField(
      controller: _hintController,
      maxLines: 3,
      minLines: 2,
      decoration: InputDecoration(
        hintText: '自定义提示（可选）\n想加入什么特别的小元素？',
        hintStyle: TextStyle(fontSize: 13, color: theme.textTertiary),
        filled: true,
        fillColor: theme.paper,
        contentPadding: EdgeInsets.all(theme.spacingMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.radiusMd),
          borderSide: BorderSide(color: theme.stageSurface, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.radiusMd),
          borderSide: BorderSide(color: theme.stageSurface, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.radiusMd),
          borderSide: BorderSide(color: theme.stageAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLoading(AppTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingXl),
      decoration: BoxDecoration(
        color: theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.stageSurface, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: theme.stageAccent),
          SizedBox(height: theme.spacingLg),
          Text(
            '正在编织一个温柔的故事…',
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
            ),
          ),
          SizedBox(height: theme.spacingXs),
          Text(
            '🌙 ✨ 📖',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHint(AppTheme theme, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingXl),
      decoration: BoxDecoration(
        color: theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.stageSurface, width: 1),
      ),
      child: Column(
        children: [
          Text('🌙', style: const TextStyle(fontSize: 40)),
          SizedBox(height: theme.spacingMd),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: theme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(AppTheme theme) {
    final story = _story!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        color: theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.stageSurface, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.spacingMd),
              child: Text(
                story.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
          SizedBox(height: theme.spacingXs),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacingSm,
                vertical: theme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: theme.stageAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(theme.radiusPill),
              ),
              child: Text(
                '主题：${story.theme}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.stageAccentDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: theme.spacingLg),
          _buildStoryContent(story.content, theme),
          SizedBox(height: theme.spacingLg),
          _buildMoralLessons(story.moralLessons, theme),
          SizedBox(height: theme.spacingLg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isGenerating ? null : _generate,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('重新生成'),
                ),
              ),
              SizedBox(width: theme.spacingSm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已保存到日记（开发中）'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bookmark_add, size: 18),
                  label: const Text('保存到日记'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContent(String content, AppTheme theme) {
    final paragraphs =
        content.split('\n').where((p) => p.trim().isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < paragraphs.length; i++) ...[
          Text(
            paragraphs[i].trim(),
            style: TextStyle(
              fontSize: 15,
              height: 1.85,
              color: theme.textPrimary,
            ),
          ),
          if (i < paragraphs.length - 1) SizedBox(height: theme.spacingMd),
        ],
      ],
    );
  }

  Widget _buildMoralLessons(List<String> lessons, AppTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        color: theme.stageAccent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(
          color: theme.stageAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              SizedBox(width: theme.spacingXs),
              Text(
                '故事寓意',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacingSm),
          Wrap(
            spacing: theme.spacingSm,
            runSpacing: theme.spacingSm,
            children: lessons.map((lesson) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacingMd,
                  vertical: theme.spacingXs + 2,
                ),
                decoration: BoxDecoration(
                  color: theme.paper,
                  borderRadius: BorderRadius.circular(theme.radiusPill),
                  border: Border.all(
                    color: theme.stageAccent.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  lesson,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.stageAccentDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ==================== 成长寄语 Tab ====================

class GrowthLetterTab extends ConsumerStatefulWidget {
  final Baby baby;

  const GrowthLetterTab({super.key, required this.baby});

  @override
  ConsumerState<GrowthLetterTab> createState() => _GrowthLetterTabState();
}

class _GrowthLetterTabState extends ConsumerState<GrowthLetterTab> {
  final TextEditingController _hintController = TextEditingController();
  late final List<String> _occasions;
  int _selectedOccasionIndex = 0;
  bool _isGenerating = false;
  GeneratedLetter? _letter;

  @override
  void initState() {
    super.initState();
    _occasions =
        ref.read(storyGeneratorServiceProvider).getLetterOccasions();
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);
    try {
      final service = ref.read(storyGeneratorServiceProvider);
      final letter = await service.generateGrowthLetter(
        babyId: widget.baby.id,
        occasion: _occasions[_selectedOccasionIndex],
        customHint: _hintController.text.trim().isEmpty
            ? null
            : _hintController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _letter = letter;
        _isGenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('生成失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(theme, '选择场合'),
          SizedBox(height: theme.spacingSm),
          _buildOccasionChips(theme),
          SizedBox(height: theme.spacingMd),
          _buildHintField(theme),
          SizedBox(height: theme.spacingMd),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isGenerating ? null : _generate,
              icon: const Icon(Icons.mail, size: 20),
              label: Text(_letter == null ? '生成寄语' : '重新生成'),
            ),
          ),
          SizedBox(height: theme.spacingLg),
          if (_isGenerating)
            _buildLoading(theme)
          else if (_letter != null)
            _buildLetterCard(theme)
          else
            _buildEmptyHint(theme, '选一个场合，为宝宝写一封温暖的家书吧'),
          SizedBox(height: theme.spacingXl),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(AppTheme theme, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.textSecondary,
      ),
    );
  }

  Widget _buildOccasionChips(AppTheme theme) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _occasions.length,
        separatorBuilder: (_, __) => SizedBox(width: theme.spacingSm),
        itemBuilder: (context, index) {
          final isSelected = _selectedOccasionIndex == index;
          return Center(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedOccasionIndex = index);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacingMd,
                  vertical: theme.spacingXs + 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.stageAccent
                      : theme.stageSurface,
                  borderRadius: BorderRadius.circular(theme.radiusPill),
                  border: Border.all(
                    color: isSelected
                        ? theme.stageAccent
                        : theme.textTertiary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _occasions[index],
                  style: TextStyle(
                    color: isSelected
                        ? theme.onAccent
                        : theme.textSecondary,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHintField(AppTheme theme) {
    return TextField(
      controller: _hintController,
      maxLines: 3,
      minLines: 2,
      decoration: InputDecoration(
        hintText: '自定义提示（可选）\n想对宝宝说些什么特别的话？',
        hintStyle: TextStyle(fontSize: 13, color: theme.textTertiary),
        filled: true,
        fillColor: theme.paper,
        contentPadding: EdgeInsets.all(theme.spacingMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.radiusMd),
          borderSide: BorderSide(color: theme.stageSurface, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.radiusMd),
          borderSide: BorderSide(color: theme.stageSurface, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.radiusMd),
          borderSide: BorderSide(color: theme.stageAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLoading(AppTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingXl),
      decoration: BoxDecoration(
        color: theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.stageSurface, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: theme.stageAccent),
          SizedBox(height: theme.spacingLg),
          Text(
            '正在书写一封温暖的家书…',
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
            ),
          ),
          SizedBox(height: theme.spacingXs),
          Text(
            '💌 ✍️ 🌸',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHint(AppTheme theme, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingXl),
      decoration: BoxDecoration(
        color: theme.paper,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.stageSurface, width: 1),
      ),
      child: Column(
        children: [
          Text('💌', style: const TextStyle(fontSize: 40)),
          SizedBox(height: theme.spacingMd),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: theme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterCard(AppTheme theme) {
    final letter = _letter!;
    // 信纸色：温暖偏黄的奶油色
    const letterPaperColor = Color(0xFFFFF6DC);
    const letterLineColor = Color(0xFFE8D9A8);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        color: letterPaperColor,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: letterLineColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.spacingMd),
              child: Text(
                letter.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5C4A2A),
                  letterSpacing: 1.5,
                  height: 1.4,
                ),
              ),
            ),
          ),
          SizedBox(height: theme.spacingSm),
          Center(
            child: Container(
              width: 48,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFFB8A165),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          SizedBox(height: theme.spacingLg),
          _buildLetterContent(letter.content, theme),
          SizedBox(height: theme.spacingLg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isGenerating ? null : _generate,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('重新生成'),
                ),
              ),
              SizedBox(width: theme.spacingSm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已保存到寄语本（开发中）'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bookmark_add, size: 18),
                  label: const Text('保存到寄语本'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLetterContent(String content, AppTheme theme) {
    final paragraphs =
        content.split('\n').where((p) => p.trim().isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < paragraphs.length; i++) ...[
          Text(
            paragraphs[i].trim(),
            style: TextStyle(
              fontSize: 15,
              height: 2.0,
              color: const Color(0xFF4A3F28),
              letterSpacing: 0.3,
            ),
          ),
          if (i < paragraphs.length - 1) SizedBox(height: theme.spacingMd),
        ],
      ],
    );
  }
}
