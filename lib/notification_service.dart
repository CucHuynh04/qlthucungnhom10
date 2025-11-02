// lib/notification_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'pet_service.dart';

// Top-level function for handling background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
}

class NotificationService extends ChangeNotifier {
  final List<Map<String, dynamic>> _notifications = [];
  bool _hasUnreadNotifications = false;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  String? _fcmToken;
  bool _localNotificationsInitialized = false;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get hasUnreadNotifications => _hasUnreadNotifications;
  String? get fcmToken => _fcmToken;

  // Initialize Local Notifications
  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) return;
    
    // Initialize timezone
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        print('Notification tapped: ${details.payload}');
      },
    );
    
    _localNotificationsInitialized = true;
    print('Local notifications initialized');
  }

  // Schedule vaccination notification
  Future<void> scheduleVaccinationNotification({
    required String petName,
    required String vaccineName,
    required DateTime dueDate,
    required int notificationId,
  }) async {
    await _initializeLocalNotifications();

    final androidDetails = AndroidNotificationDetails(
      'vaccination_channel',
      'Vaccination Reminders',
      channelDescription: 'Notifications for upcoming pet vaccinations',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = dueDate.subtract(const Duration(days: 1)); // Remind 1 day before
    final now = DateTime.now();

    if (scheduledDate.isAfter(now)) {
      await _localNotifications.zonedSchedule(
        notificationId,
        'Đến hạn tiêm chủng!',
        '$petName cần tiêm vaccine: $vaccineName vào ngày mai',
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'vaccination_$petName',
      );
      print('Scheduled vaccination notification for $petName on ${scheduledDate.toString()}');
    }
  }

  // Schedule notifications for all upcoming vaccinations
  Future<void> scheduleAllVaccinationNotifications(PetService petService) async {
    await _initializeLocalNotifications();
    
    // Cancel all existing notifications
    await _localNotifications.cancelAll();
    
    int notificationId = 0;
    final now = DateTime.now();
    
    for (final pet in petService.pets) {
      for (final vaccination in pet.vaccinationHistory) {
        if (vaccination.nextDueDate != null) {
          await scheduleVaccinationNotification(
            petName: pet.name,
            vaccineName: vaccination.vaccineName,
            dueDate: vaccination.nextDueDate!,
            notificationId: notificationId++,
          );
        }
      }
    }
    
    print('Scheduled ${notificationId} vaccination notifications');
  }

  // Initialize FCM
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        print('FCM Token: $_fcmToken');

        // Listen to token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          print('FCM Token refreshed: $newToken');
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle when user taps notification
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Handle notification when app is opened from terminated state
        RemoteMessage? initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }
      }
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Add notification to local list
    _notifications.insert(0, {
      'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'chat',
      'title': message.notification?.title ?? 'Tin nhắn mới',
      'message': message.notification?.body ?? '',
      'date': DateTime.now(),
      'isRead': false,
    });
    _hasUnreadNotifications = true;
    notifyListeners();
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Handle notification tap - navigate to chat screen
    _notifications.insert(0, {
      'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'chat',
      'title': message.notification?.title ?? 'Tin nhắn mới',
      'message': message.notification?.body ?? '',
      'date': DateTime.now(),
      'isRead': false,
    });
    _hasUnreadNotifications = true;
    notifyListeners();
  }

  void checkScheduleNotifications(PetService petService) {
    _notifications.clear();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Kiểm tra lịch hẹn trong vòng 7 ngày tới
    for (int i = 0; i < 7; i++) {
      final checkDate = today.add(Duration(days: i));
      
      // Thêm các lịch hẹn từ schedules
      for (final schedule in petService.schedules) {
        final scheduleDate = DateTime(
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
        );
        if (scheduleDate.isAtSameMomentAs(checkDate)) {
          final pet = petService.getPetById(schedule.petId);
          if (pet != null) {
            _notifications.add({
              'id': 'schedule_${schedule.id}',
              'type': 'schedule',
              'title': 'Lịch hẹn ${pet.name}',
              'message': '${schedule.title} - ${schedule.type}',
              'date': checkDate,
              'petId': pet.id,
              'isRead': false,
            });
          }
        }
      }
      
      // Thêm các lịch hẹn từ vaccination due dates
      for (final pet in petService.pets) {
        for (final vaccination in pet.vaccinationHistory) {
          if (vaccination.nextDueDate != null) {
            final dueDate = DateTime(
              vaccination.nextDueDate!.year,
              vaccination.nextDueDate!.month,
              vaccination.nextDueDate!.day,
            );
            if (dueDate.isAtSameMomentAs(checkDate)) {
              _notifications.add({
                'id': 'vaccination_${pet.id}_${vaccination.id}',
                'type': 'vaccination',
                'title': 'Tiêm chủng ${pet.name}',
                'message': 'Đến hạn tiêm vaccine: ${vaccination.vaccineName}',
                'date': checkDate,
                'petId': pet.id,
                'isRead': false,
              });
            }
          }
        }
      }
    }
    
    _hasUnreadNotifications = _notifications.any((n) => !n['isRead']);
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      _hasUnreadNotifications = _notifications.any((n) => !n['isRead']);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    _hasUnreadNotifications = false;
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _hasUnreadNotifications = false;
    notifyListeners();
  }
}





