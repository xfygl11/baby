import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    _initialized = true;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    await init();

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'xiaoyuanbao_channel',
      '小元宝成长记',
      channelDescription: '宝宝成长记录提醒',
      importance: importance,
      priority: priority,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails();

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await init();

    final scheduledTZTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'xiaoyuanbao_reminder',
      '疫苗/喂养提醒',
      channelDescription: '疫苗接种和喂养提醒',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails();

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> showVaccineReminder({
    required String vaccineName,
    required DateTime vaccinationDate,
    required int daysLeft,
  }) async {
    String body;
    if (daysLeft == 0) {
      body = '今天是 $vaccineName 的接种日，别忘了带宝宝去接种哦～';
    } else if (daysLeft == 1) {
      body = '明天就要接种 $vaccineName 了，提前做好准备～';
    } else {
      body = '还有 $daysLeft 天就要接种 $vaccineName 了，记得提前预约哦～';
    }

    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '💉 疫苗提醒',
      body: body,
    );
  }

  Future<void> showFeedingReminder() async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🍼 该喂奶啦',
      body: '宝宝可能饿了，来记录一下这次的喂养吧～',
    );
  }

  Future<void> showSleepReminder() async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '😴 该睡觉啦',
      body: '宝宝到了入睡时间了，来帮宝宝睡个好觉吧～',
    );
  }

  Future<void> showTemperatureCheckReminder() async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🌡️ 该测体温了',
      body: '宝宝发烧了，该复测一下体温看看情况～',
    );
  }

  Future<void> showDailySummary() async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '📝 今日总结',
      body: '今天的记录已经整理好了，来看看宝宝的成长吧～',
    );
  }

  Future<bool> requestPermissions() async {
    await init();
    final androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }
    
    return true;
  }
}
