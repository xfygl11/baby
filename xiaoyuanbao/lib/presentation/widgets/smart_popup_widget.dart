import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_enums.dart';
import '../../services/popup/smart_popup_service.dart';

/// 智能弹窗组件
///
/// 参考美柚睡眠小弹窗设计，从底部滑入显示一个轻量级卡片，
/// 包含图标、标题、副标题、消息和操作按钮。
class SmartPopupWidget extends StatelessWidget {
  final SmartPopup popup;

  const SmartPopupWidget({super.key, required this.popup});

  /// 弹窗类型与图标的映射
  static const Map<PopupType, IconData> _typeIcons = {
    PopupType.sleepWindow: Icons.bedtime,
    PopupType.sleepWake: Icons.alarm,
    PopupType.nightWake: Icons.nights_stay,
    PopupType.feedingInterval: Icons.baby_changing_station,
    PopupType.vaccineReminder: Icons.vaccines,
    PopupType.temperatureCheck: Icons.thermostat,
    PopupType.medicationReminder: Icons.medication,
    PopupType.milestoneCheck: Icons.emoji_events,
    PopupType.dailySummary: Icons.summarize,
    PopupType.birthday: Icons.cake,
    PopupType.anomalyAlert: Icons.warning,
  };

  IconData get _icon => _typeIcons[popup.type] ?? Icons.notifications;

  /// 根据弹窗优先级返回强调色
  Color _accentColor(AppTheme theme) {
    switch (popup.priority) {
      case PopupPriority.p0:
        return theme.danger;
      case PopupPriority.p1:
        return theme.warning;
      case PopupPriority.p2:
        return theme.info;
      case PopupPriority.p3:
        return theme.milestoneGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final accent = _accentColor(theme);
    final primaryActions = popup.actions.where((a) => a.isPrimary).toList();
    final secondaryActions = popup.actions.where((a) => !a.isPrimary).toList();

    return Material(
      color: theme.paper,
      borderRadius: BorderRadius.circular(theme.radiusLg),
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(theme.spacingLg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(theme.radiusLg),
          border: Border.all(color: accent.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                  ),
                  child: Icon(_icon, color: accent, size: 24),
                ),
                SizedBox(width: theme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        popup.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (popup.subtitle != null) ...[
                        SizedBox(height: theme.spacingXs),
                        Text(
                          popup.subtitle!,
                          style: TextStyle(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20, color: theme.textTertiary),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            SizedBox(height: theme.spacingMd),
            Text(
              popup.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: theme.textSecondary,
                  ),
            ),
            SizedBox(height: theme.spacingLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final action in secondaryActions) ...[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(action.label),
                  ),
                  SizedBox(width: theme.spacingSm),
                ],
                for (final action in primaryActions)
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    child: Text(action.label),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 从底部滑入显示弹窗
  ///
  /// 带半透明遮罩，点击遮罩可关闭。
  /// P0/P1 级别弹窗不会自动消失，其余级别 10 秒后自动消失。
  static void show(BuildContext context, SmartPopup popup) {
    final autoDismiss = popup.priority != PopupPriority.p0 &&
        popup.priority != PopupPriority.p1;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _SmartPopupHost(popup: popup, autoDismiss: autoDismiss);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
        return SlideTransition(position: slide, child: child);
      },
    );
  }
}

/// 弹窗宿主，负责管理自动消失定时器和遮罩点击关闭。
class _SmartPopupHost extends StatefulWidget {
  final SmartPopup popup;
  final bool autoDismiss;

  const _SmartPopupHost({
    required this.popup,
    required this.autoDismiss,
  });

  @override
  State<_SmartPopupHost> createState() => _SmartPopupHostState();
}

class _SmartPopupHostState extends State<_SmartPopupHost> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoDismiss) {
      _timer = Timer(const Duration(seconds: 10), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              theme.spacingLg,
              0,
              theme.spacingLg,
              theme.spacingXl + bottomPadding,
            ),
            child: SmartPopupWidget(popup: widget.popup),
          ),
        ),
      ),
    );
  }
}
