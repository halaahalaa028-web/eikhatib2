import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import '../api/dio_consumer.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:local_notifier/local_notifier.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class FcmHelper {
  static final _dioConsumer = DioConsumer(dio: Dio());
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'إشعارات الخطيب الهامة',
    description: 'يتم استخدام هذه القناة لإشعارات التطبيق الهامة.',
    importance: Importance.max,
  );

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();

      // Initialize Local Notifications for Android and iOS
      if (Platform.isAndroid || Platform.isIOS) {
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const DarwinInitializationSettings initializationSettingsDarwin =
            DarwinInitializationSettings();
        
        const InitializationSettings initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );
        
        await _localNotifications.initialize(
          settings: initializationSettings,
        );

        // Request Android 13+ Notification Permission
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();

        // Create Android Notification Channel
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);
      }

      // Initialize Local Notifier for Windows
      if (Platform.isWindows) {
        await localNotifier.setup(
          appName: 'الخطيب',
          shortcutPolicy: ShortcutPolicy.requireCreate,
        );
      }

      // FCM is only supported on Android, iOS, Web, macOS
      if (Platform.isAndroid || Platform.isIOS) {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        FirebaseMessaging messaging = FirebaseMessaging.instance;

        // Handle iOS foreground options
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          debugPrint('User granted permission');
        }

        // Handle token
        String? token = await messaging.getToken();
        if (token != null) {
          debugPrint('FCM Token: $token');
          await updateTokenOnServer(token);
        }

        messaging.onTokenRefresh.listen((newToken) {
          updateTokenOnServer(newToken);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Got a message whilst in the foreground!');
          _showNotification(message);
        });
      }
    } catch (e) {
      debugPrint('FCM Init Error: $e');
    }
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    
    if (notification != null) {
      if (Platform.isWindows) {
        LocalNotification localNotification = LocalNotification(
          title: notification.title ?? '',
          body: notification.body ?? '',
        );
        await localNotification.show();
        return;
      }

      String? imageUrl = message.data['imageUrl'] ?? (android?.imageUrl);
      BigPictureStyleInformation? bigPictureStyleInformation;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        final String filePath = await _downloadAndSaveFile(imageUrl, 'notification_img');
        bigPictureStyleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(filePath),
          contentTitle: notification.title,
          summaryText: notification.body,
        );
      }

      await _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: _channel.importance,
            priority: Priority.high,
            styleInformation: bigPictureStyleInformation,
          ),
        ),
      );
    }
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final Response response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
    final File file = File(filePath);
    await file.writeAsBytes(response.data);
    return filePath;
  }

  static Future<void> updateTokenOnServer(String token) async {
    try {
      await _dioConsumer.patch('auth/fcm-token', data: {'fcm_token': token});
      debugPrint('FCM Token synced with server.');
    } catch (e) {
      debugPrint('Failed to sync FCM Token: $e');
    }
  }
}
