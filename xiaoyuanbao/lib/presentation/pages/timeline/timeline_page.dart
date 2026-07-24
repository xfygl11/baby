import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';

class TimelinePage extends ConsumerWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = AppTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('记录时光'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(appTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(context, appTheme),
            SizedBox(height: appTheme.spacingLg),
            _buildTimelineList(context, appTheme),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, AppTheme appTheme) {
    final now = DateTime.now();
    final dateStr = '${now.year}年${now.month}月${now.day}日';

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: appTheme.spacingMd,
            vertical: appTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: appTheme.stageAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(appTheme.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 16, color: appTheme.stageAccent),
              SizedBox(width: appTheme.spacingXs),
              Text(
                dateStr,
                style: TextStyle(
                  color: appTheme.stageAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.filter_list),
        ),
      ],
    );
  }

  Widget _buildTimelineList(BuildContext context, AppTheme appTheme) {
    final items = [
      {'icon': '🍼', 'title': '喂养', 'time': '08:30', 'subtitle': '奶粉 120ml'},
      {'icon': '😴', 'title': '睡眠', 'time': '09:00 - 10:30', 'subtitle': '小睡 1.5小时'},
      {'icon': '👶', 'title': '尿布', 'time': '10:45', 'subtitle': '湿'},
    ];

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: appTheme.spacingSm),
          _buildTimelineItem(context, appTheme, items[i]),
        ],
        if (items.isEmpty)
          Center(
            child: Column(
              children: [
                SizedBox(height: appTheme.spacingXxl * 2),
                Icon(
                  Icons.timeline,
                  size: 64,
                  color: appTheme.textTertiary,
                ),
                SizedBox(height: appTheme.spacingLg),
                Text(
                  '还没有记录呢',
                  style: TextStyle(
                    fontSize: 16,
                    color: appTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, AppTheme appTheme, Map<String, String> item) {
    return Container(
      padding: EdgeInsets.all(appTheme.spacingMd),
      decoration: BoxDecoration(
        color: appTheme.stageSurface,
        borderRadius: BorderRadius.circular(appTheme.radiusMd),
        border: Border.all(color: appTheme.textTertiary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: appTheme.stageAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(appTheme.radiusMd),
            ),
            alignment: Alignment.center,
            child: Text(item['icon']!, style: const TextStyle(fontSize: 24)),
          ),
          SizedBox(width: appTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                SizedBox(height: 2),
                Text(
                  item['subtitle']!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            item['time']!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appTheme.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}
