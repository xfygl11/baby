import 'package:intl/intl.dart';

class AgeResult {
  final int years;
  final int months;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  const AgeResult({
    required this.years,
    required this.months,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  double get totalMonths => years * 12 + months + days / 30.0;

  double get totalDays => years * 365 + months * 30 + days.toDouble();

  String get compact {
    if (years > 0) {
      return '${years}岁${months}月';
    } else if (months > 0) {
      return '${months}月${days}天';
    } else {
      return '${days}天';
    }
  }

  String get precise {
    return '${years}岁 ${months}月 ${days}天 ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class DateTimeUtils {
  static AgeResult calculateAge(DateTime birthDate, {DateTime? now}) {
    final current = now ?? DateTime.now();
    
    int years = current.year - birthDate.year;
    int months = current.month - birthDate.month;
    int days = current.day - birthDate.day;
    int hours = current.hour - birthDate.hour;
    int minutes = current.minute - birthDate.minute;
    int seconds = current.second - birthDate.second;

    if (seconds < 0) {
      minutes -= 1;
      seconds += 60;
    }
    if (minutes < 0) {
      hours -= 1;
      minutes += 60;
    }
    if (hours < 0) {
      days -= 1;
      hours += 24;
    }
    if (days < 0) {
      months -= 1;
      final prevMonth = DateTime(current.year, current.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    return AgeResult(
      years: years,
      months: months,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  static double monthsBetween(DateTime from, DateTime to) {
    final years = to.year - from.year;
    final months = to.month - from.month;
    final days = to.day - from.day;
    return years * 12 + months + days / 30.0;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTimeCn(DateTime date) {
    return DateFormat('yyyy年M月d日 HH:mm').format(date);
  }

  static String formatDateCn(DateTime date) {
    return DateFormat('yyyy年M月d日').format(date);
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}小时${minutes}分钟';
    }
    return '${minutes}分钟';
  }

  static String relativeTime(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final diff = current.difference(date);
    
    if (diff.inSeconds < 60) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return formatDate(date);
    }
  }

  static DateTime parseRelativeTime(String input, {DateTime? reference}) {
    final now = reference ?? DateTime.now();
    final lower = input.toLowerCase().trim();
    
    if (lower.contains('今天') || lower.contains('今天')) {
      return now;
    }
    if (lower.contains('昨天')) {
      return now.subtract(const Duration(days: 1));
    }
    if (lower.contains('前天')) {
      return now.subtract(const Duration(days: 2));
    }
    if (lower.contains('明天')) {
      return now.add(const Duration(days: 1));
    }
    if (lower.contains('刚才') || lower.contains('刚刚')) {
      return now.subtract(const Duration(minutes: 10));
    }
    
    return now;
  }
}
