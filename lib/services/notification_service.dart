import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../data/models/wishlist_item.dart';
import 'hive_service.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Whether the local notifications plugin is usable on this platform.
  ///
  /// Desktop (Windows/Linux) has no bundled implementation, so any plugin
  /// call would throw a MissingPluginException. We disable the feature there
  /// instead of crashing the app.
  static bool get _supported =>
      !kIsWeb &&
      (Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isMacOS ||
          Platform.isWindows);

  static Future<void> init() async {
    if (_initialized) return;
    if (!_supported) {
      _initialized = true;
      return;
    }

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Request permissions for Android 13+
      final androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();

      _initialized = true;
    } catch (_) {
      _initialized = true; // mark as done so we never retry & block startup
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap if needed
  }

  // Schedule monthly savings reminder
  static Future<void> scheduleMonthlyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized || !_supported) return;
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'monthly_savings',
            'Pengingat Menabung Bulanan',
            channelDescription: 'Notifikasi pengingat untuk menabung tiap bulan',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }

  // Schedule target date reminder (3 days before, 1 day before, on the day)
  static Future<void> scheduleTargetDateReminders(WishlistItem item) async {
    if (!_initialized || !_supported) return;
    if (item.targetDate == null || item.isTargetReached) return;

    final targetDate = item.targetDate!;
    final now = DateTime.now();
    final difference = targetDate.difference(now).inDays;

    final reminders = <int, String>{
      3: '3 hari lagi',
      1: 'Besok',
      0: 'Hari ini',
    };

    try {
      for (final entry in reminders.entries) {
        if (difference >= entry.key) {
          final notificationDate = targetDate.subtract(Duration(days: entry.key));
          if (notificationDate.isAfter(now)) {
            final id = item.id.hashCode + entry.key * 1000;
            await _flutterLocalNotificationsPlugin.zonedSchedule(
              id,
              'Target Mendekat: ${item.name}',
              'Target ${entry.value} (${_formatDate(targetDate)}) - Dana: ${_formatCurrency(item.targetPrice ?? 0)}',
              tz.TZDateTime.from(notificationDate, tz.local),
              const NotificationDetails(
              android: AndroidNotificationDetails(
                'target_dates',
                'Target Wishlist',
                channelDescription: 'Notifikasi mendekati tanggal target wishlist',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }
    }

    // Overdue notification (1 day after target)
    if (difference < 0) {
      final overdueDate = targetDate.add(const Duration(days: 1));
      if (overdueDate.isAfter(now)) {
        final id = item.id.hashCode + 9999;
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          'Target Terlewat: ${item.name}',
          'Target sudah lewat (${_formatDate(targetDate)}) - Sisa: ${_formatCurrency(item.remainingAmount)}',
          tz.TZDateTime.from(overdueDate, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'overdue',
                'Target Terlewat',
                channelDescription: 'Notifikasi target wishlist yang sudah terlewat',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }
    } catch (_) {}
  }

  // Cancel all notifications for a wishlist item
  static Future<void> cancelItemNotifications(String itemId) async {
    if (!_initialized || !_supported) return;
    try {
      final id = itemId.hashCode;
      await _flutterLocalNotificationsPlugin.cancel(id);
      await _flutterLocalNotificationsPlugin.cancel(id + 3000);
      await _flutterLocalNotificationsPlugin.cancel(id + 1000);
      await _flutterLocalNotificationsPlugin.cancel(id + 9999);
    } catch (_) {}
  }

  // Reschedule all reminders for all items
  static Future<void> rescheduleAllReminders() async {
    if (!_initialized || !_supported) return;
    try {
      final items = HiveService.getWishlistBox().values.toList();
      await cancelAllNotifications();

      // Monthly reminder at 9 AM
      await scheduleMonthlyReminder(
        id: 10000,
        title: 'Waktunya Menabung!',
        body: 'Jangan lupa tabung hari ini untuk mencapai target wishlistmu.',
        hour: 9,
        minute: 0,
      );

      // Target date reminders
      for (final item in items) {
        await scheduleTargetDateReminders(item);
      }
    } catch (_) {}
  }

  static Future<void> cancelAllNotifications() async {
    if (!_initialized || !_supported) return;
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (_) {}
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static String _formatDate(DateTime date) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  static String _formatCurrency(double amount) {
    final value = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);
      final remaining = value.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString()}';
  }
}