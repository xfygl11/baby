import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// 通用错误组件
///
/// 居中展示错误图标、错误消息，以及可选的重试按钮。
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
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
            Icon(Icons.error_outline, size: 64, color: theme.danger),
            SizedBox(height: theme.spacingLg),
            Text(
              message,
              style: TextStyle(color: theme.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: theme.spacingLg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
