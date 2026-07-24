import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = AppTheme.of(context);
    final babyAsync = ref.watch(currentBabyProvider);

    return Scaffold(
      body: babyAsync.when(
        data: (baby) {
          return ListView(
            children: [
              _buildHeader(context, appTheme, baby?.name ?? '未设置'),
              SizedBox(height: appTheme.spacingMd),
              _buildSectionTitle(context, '宝宝档案'),
              _buildListTile(
                context,
                appTheme,
                icon: Icons.child_care,
                title: '宝宝信息',
                subtitle: baby?.name ?? '未设置',
              ),
              _buildListTile(
                context,
                appTheme,
                icon: Icons.vaccines,
                title: '疫苗计划',
                subtitle: '查看接种记录',
              ),
              _buildListTile(
                context,
                appTheme,
                icon: Icons.emoji_events,
                title: '里程碑',
                subtitle: '发育里程碑管理',
              ),
              SizedBox(height: appTheme.spacingMd),
              _buildSectionTitle(context, '设置'),
              _buildListTile(
                context,
                appTheme,
                icon: Icons.palette_outlined,
                title: '主题设置',
                subtitle: '跟随系统',
              ),
              _buildListTile(
                context,
                appTheme,
                icon: Icons.notifications_none,
                title: '提醒设置',
                subtitle: '智能提醒',
              ),
              _buildListTile(
                context,
                appTheme,
                icon: Icons.cloud_outlined,
                title: '数据备份',
                subtitle: '本地存储',
              ),
              SizedBox(height: appTheme.spacingMd),
              _buildSectionTitle(context, '关于'),
              _buildListTile(
                context,
                appTheme,
                icon: Icons.info_outline,
                title: '关于萱萱',
                subtitle: 'v1.0.0',
              ),
              _buildListTile(
                context,
                appTheme,
                icon: Icons.help_outline,
                title: '帮助与反馈',
                subtitle: '',
              ),
              SizedBox(height: appTheme.spacingXxl),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppTheme appTheme, String babyName) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        appTheme.spacingLg,
        appTheme.spacingXxl + 20,
        appTheme.spacingLg,
        appTheme.spacingXxl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appTheme.stageAccent, appTheme.stageAccentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: Colors.white30, width: 2),
            ),
            child: const Icon(Icons.child_care, size: 40, color: Colors.white),
          ),
          SizedBox(width: appTheme.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  babyName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: appTheme.spacingXs),
                const Text(
                  '健康快乐每一天',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final appTheme = AppTheme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        appTheme.spacingLg,
        appTheme.spacingMd,
        appTheme.spacingLg,
        appTheme.spacingSm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    AppTheme appTheme, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: appTheme.spacingMd,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: appTheme.stageSurface,
        borderRadius: BorderRadius.circular(appTheme.radiusMd),
      ),
      child: ListTile(
        leading: Icon(icon, color: appTheme.stageAccent),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        trailing: Icon(Icons.chevron_right, color: appTheme.textTertiary),
        onTap: () {},
      ),
    );
  }
}
