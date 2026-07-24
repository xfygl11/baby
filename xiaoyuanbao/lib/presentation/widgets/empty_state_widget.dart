import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// 通用空状态组件
///
/// 居中展示图标、标题、副标题，以及可选的操作按钮。
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.textTertiary),
            SizedBox(height: theme.spacingLg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: theme.spacingSm),
            Text(
              subtitle,
              style: TextStyle(color: theme.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: theme.spacingLg),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
