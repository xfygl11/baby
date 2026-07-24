import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum ThemeModeOption { system, light, dark }
enum ThemeColorOption { age, system, custom }
enum FontSizeOption { standard, large, extraLarge }
enum AiAutonomyLevel { suggestion, assist, efficient, auto }

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeModeOption _themeMode = ThemeModeOption.system;
  ThemeColorOption _themeColor = ThemeColorOption.age;
  FontSizeOption _fontSize = FontSizeOption.standard;

  bool _vaccineReminder = true;
  bool _feedingReminder = true;
  bool _sleepReminder = true;
  bool _dailySummaryReminder = true;
  bool _smartPopupEnabled = true;
  String _dndStart = '22:00';
  String _dndEnd = '07:00';

  AiAutonomyLevel _aiAutonomy = AiAutonomyLevel.assist;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: EdgeInsets.all(theme.spacingLg),
        children: [
          _buildPersonalizationSection(theme),
          SizedBox(height: theme.spacingXl),
          _buildNotificationSection(theme),
          SizedBox(height: theme.spacingXl),
          _buildAiSection(theme),
          SizedBox(height: theme.spacingXl),
          _buildDataSection(theme),
          SizedBox(height: theme.spacingXl),
          _buildAboutSection(theme),
          SizedBox(height: theme.spacingXxl),
        ],
      ),
    );
  }

  Widget _buildPersonalizationSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, '个性化'),
        SizedBox(height: theme.spacingMd),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildThemeModeTile(theme),
              _buildDivider(theme),
              _buildThemeColorTile(theme),
              _buildDivider(theme),
              _buildFontSizeTile(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeTile(AppTheme theme) {
    return _buildNavigationTile(
      theme,
      icon: Icons.dark_mode_outlined,
      title: '主题模式',
      subtitle: _themeModeLabel,
      onTap: () => _showThemeModeDialog(),
    );
  }

  Widget _buildThemeColorTile(AppTheme theme) {
    return _buildNavigationTile(
      theme,
      icon: Icons.palette_outlined,
      title: '主题色系',
      subtitle: _themeColorLabel,
      onTap: () => _showThemeColorDialog(),
    );
  }

  Widget _buildFontSizeTile(AppTheme theme) {
    return _buildNavigationTile(
      theme,
      icon: Icons.text_fields,
      title: '字体大小',
      subtitle: _fontSizeLabel,
      onTap: () => _showFontSizeDialog(),
    );
  }

  Widget _buildNotificationSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, '通知设置'),
        SizedBox(height: theme.spacingMd),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildSwitchTile(
                theme,
                icon: Icons.vaccines_outlined,
                title: '疫苗提醒',
                subtitle: '接种前准时提醒',
                value: _vaccineReminder,
                onChanged: (v) => setState(() => _vaccineReminder = v),
              ),
              _buildDivider(theme),
              _buildSwitchTile(
                theme,
                icon: Icons.fastfood_outlined,
                title: '喂养提醒',
                subtitle: '按时提醒喂养',
                value: _feedingReminder,
                onChanged: (v) => setState(() => _feedingReminder = v),
              ),
              _buildDivider(theme),
              _buildSwitchTile(
                theme,
                icon: Icons.bedtime_outlined,
                title: '睡眠提醒',
                subtitle: '提醒宝宝睡觉',
                value: _sleepReminder,
                onChanged: (v) => setState(() => _sleepReminder = v),
              ),
              _buildDivider(theme),
              _buildSwitchTile(
                theme,
                icon: Icons.description_outlined,
                title: '每日总结提醒',
                subtitle: '每天晚上推送当日总结',
                value: _dailySummaryReminder,
                onChanged: (v) => setState(() => _dailySummaryReminder = v),
              ),
              _buildDivider(theme),
              _buildSwitchTile(
                theme,
                icon: Icons.auto_awesome,
                title: '智能小弹窗',
                subtitle: 'AI 智能推送贴心提示',
                value: _smartPopupEnabled,
                onChanged: (v) => setState(() => _smartPopupEnabled = v),
              ),
            ],
          ),
        ),
        SizedBox(height: theme.spacingMd),
        Card(
          clipBehavior: Clip.antiAlias,
          child: _buildDndTile(theme),
        ),
      ],
    );
  }

  Widget _buildDndTile(AppTheme theme) {
    return _buildNavigationTile(
      theme,
      icon: Icons.do_not_disturb_off_outlined,
      title: '勿扰时段',
      subtitle: '$_dndStart - $_dndEnd',
      onTap: () => _showDndDialog(),
    );
  }

  Widget _buildAiSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'AI 助手'),
        SizedBox(height: theme.spacingMd),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildNavigationTile(
                theme,
                icon: Icons.smart_toy_outlined,
                title: 'AI 自主度',
                subtitle: _aiAutonomyLabel,
                onTap: () => _showAiAutonomyDialog(),
              ),
              _buildDivider(theme),
              _buildNavigationTile(
                theme,
                icon: Icons.cloud_outlined,
                title: '云端 AI 设置',
                subtitle: '配置 API Key 等',
                onTap: () {},
              ),
              _buildDivider(theme),
              _buildActionTile(
                theme,
                icon: Icons.delete_sweep_outlined,
                title: '清除对话历史',
                textColor: theme.danger,
                onTap: () => _showClearHistoryDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, '数据管理'),
        SizedBox(height: theme.spacingMd),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildNavigationTile(
                theme,
                icon: Icons.download_outlined,
                title: '导出数据',
                subtitle: '导出为 JSON 格式',
                onTap: () {},
              ),
              _buildDivider(theme),
              _buildNavigationTile(
                theme,
                icon: Icons.upload_outlined,
                title: '导入数据',
                subtitle: '从备份文件恢复',
                onTap: () {},
              ),
              _buildDivider(theme),
              _buildNavigationTile(
                theme,
                icon: Icons.save_outlined,
                title: '备份到本地',
                subtitle: '保存到设备存储',
                onTap: () {},
              ),
            ],
          ),
        ),
        SizedBox(height: theme.spacingMd),
        Card(
          clipBehavior: Clip.antiAlias,
          child: _buildActionTile(
            theme,
            icon: Icons.delete_forever_outlined,
            title: '清空所有数据',
            subtitle: '此操作不可撤销',
            textColor: theme.danger,
            onTap: () => _showClearDataDialog(),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, '关于'),
        SizedBox(height: theme.spacingMd),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildInfoTile(theme, '版本号', '1.0.0'),
              _buildDivider(theme),
              _buildNavigationTile(
                theme,
                icon: Icons.privacy_tip_outlined,
                title: '隐私政策',
                onTap: () {},
              ),
              _buildDivider(theme),
              _buildNavigationTile(
                theme,
                icon: Icons.article_outlined,
                title: '用户协议',
                onTap: () {},
              ),
              _buildDivider(theme),
              _buildNavigationTile(
                theme,
                icon: Icons.star_border,
                title: '给我们评分',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(AppTheme theme, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: theme.spacingSm),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: theme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildNavigationTile(
    AppTheme theme, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacingMd,
          vertical: theme.spacingMd,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.stageAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(theme.radiusMd),
              ),
              child: Icon(
                icon,
                color: theme.stageAccent,
                size: 22,
              ),
            ),
            SizedBox(width: theme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    AppTheme theme, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacingMd,
        vertical: theme.spacingSm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.stageAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(theme.radiusMd),
            ),
            child: Icon(
              icon,
              color: theme.stageAccent,
              size: 22,
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.stageAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    AppTheme theme, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacingMd,
          vertical: theme.spacingMd,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (textColor ?? theme.stageAccent).withOpacity(0.1),
                borderRadius: BorderRadius.circular(theme.radiusMd),
              ),
              child: Icon(
                icon,
                color: textColor ?? theme.stageAccent,
                size: 22,
              ),
            ),
            SizedBox(width: theme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? theme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor?.withOpacity(0.7) ?? theme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(AppTheme theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacingMd,
        vertical: theme.spacingMd,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.stageAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(theme.radiusMd),
            ),
            child: Icon(
              Icons.info_outline,
              color: theme.stageAccent,
              size: 22,
            ),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(AppTheme theme) {
    return Padding(
      padding: EdgeInsets.only(left: theme.spacingMd + 40 + theme.spacingMd),
      child: Divider(height: 1, color: theme.stageBg),
    );
  }

  String get _themeModeLabel {
    return switch (_themeMode) {
      ThemeModeOption.system => '跟随系统',
      ThemeModeOption.light => '浅色',
      ThemeModeOption.dark => '深色',
    };
  }

  String get _themeColorLabel {
    return switch (_themeColor) {
      ThemeColorOption.age => '跟随宝宝年龄',
      ThemeColorOption.system => '跟随系统壁纸',
      ThemeColorOption.custom => '自定义',
    };
  }

  String get _fontSizeLabel {
    return switch (_fontSize) {
      FontSizeOption.standard => '标准',
      FontSizeOption.large => '大',
      FontSizeOption.extraLarge => '特大（老人模式）',
    };
  }

  String get _aiAutonomyLabel {
    return switch (_aiAutonomy) {
      AiAutonomyLevel.suggestion => '仅建议',
      AiAutonomyLevel.assist => '协助模式（默认）',
      AiAutonomyLevel.efficient => '高效模式',
      AiAutonomyLevel.auto => '全自动',
    };
  }

  void _showThemeModeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('主题模式'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeModeOption.values.map((option) {
              final isSelected = _themeMode == option;
              return ListTile(
                title: Text(_themeModeLabelForOption(option)),
                trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () {
                  setState(() => _themeMode = option);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _themeModeLabelForOption(ThemeModeOption option) {
    return switch (option) {
      ThemeModeOption.system => '跟随系统',
      ThemeModeOption.light => '浅色',
      ThemeModeOption.dark => '深色',
    };
  }

  void _showThemeColorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('主题色系'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeColorOption.values.map((option) {
              final isSelected = _themeColor == option;
              return ListTile(
                title: Text(_themeColorLabelForOption(option)),
                trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () {
                  setState(() => _themeColor = option);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _themeColorLabelForOption(ThemeColorOption option) {
    return switch (option) {
      ThemeColorOption.age => '跟随宝宝年龄',
      ThemeColorOption.system => '跟随系统壁纸',
      ThemeColorOption.custom => '自定义',
    };
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('字体大小'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: FontSizeOption.values.map((option) {
              final isSelected = _fontSize == option;
              return ListTile(
                title: Text(_fontSizeLabelForOption(option)),
                trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () {
                  setState(() => _fontSize = option);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _fontSizeLabelForOption(FontSizeOption option) {
    return switch (option) {
      FontSizeOption.standard => '标准',
      FontSizeOption.large => '大',
      FontSizeOption.extraLarge => '特大（老人模式）',
    };
  }

  void _showDndDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('勿扰时段'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.schedule),
                title: Text('开始时间'),
                subtitle: Text('22:00'),
              ),
              ListTile(
                leading: Icon(Icons.schedule),
                title: Text('结束时间'),
                subtitle: Text('07:00'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _showAiAutonomyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('AI 自主度'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AiAutonomyLevel.values.map((option) {
              final isSelected = _aiAutonomy == option;
              return ListTile(
                title: Text(_aiAutonomyLabelForOption(option)),
                subtitle: Text(_aiAutonomyDescription(option)),
                trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () {
                  setState(() => _aiAutonomy = option);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _aiAutonomyLabelForOption(AiAutonomyLevel option) {
    return switch (option) {
      AiAutonomyLevel.suggestion => '仅建议',
      AiAutonomyLevel.assist => '协助模式',
      AiAutonomyLevel.efficient => '高效模式',
      AiAutonomyLevel.auto => '全自动',
    };
  }

  String _aiAutonomyDescription(AiAutonomyLevel option) {
    return switch (option) {
      AiAutonomyLevel.suggestion => '只提供建议，所有操作需手动确认',
      AiAutonomyLevel.assist => '辅助操作，重要操作需确认',
      AiAutonomyLevel.efficient => '快速执行常规操作',
      AiAutonomyLevel.auto => 'AI 自主决策和执行',
    };
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('清除对话历史'),
          content: const Text('确定要清除所有 AI 对话历史吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.of(context).danger,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('清除'),
            ),
          ],
        );
      },
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = AppTheme.of(context);
        return AlertDialog(
          title: Text('清空所有数据', style: TextStyle(color: theme.danger)),
          content: const Text(
            '警告：此操作将删除所有宝宝数据、记录和设置，且不可恢复！\n\n建议先备份数据再执行此操作。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.danger,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确认清空'),
            ),
          ],
        );
      },
    );
  }
}
