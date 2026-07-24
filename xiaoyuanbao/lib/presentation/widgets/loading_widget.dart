import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// 通用加载组件
///
/// 居中展示 CircularProgressIndicator，可附带可选的提示消息。
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.stageAccent),
          if (message != null) ...[
            SizedBox(height: theme.spacingLg),
            Text(
              message!,
              style: TextStyle(color: theme.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
