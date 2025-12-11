import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static Future<void> init() async {
    await requestPermission();

    // Register foreground listener
    OnForegroundMessageListener();
  }

  static Future<String?> getFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
    return token;
  }

  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print("🔵 Background Message ID: ${message.messageId}");
  }

  static void OnForegroundMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🟢 Foreground Message: ${message.data.toString()}");
    });
  }

  static Future<void> requestPermission() async {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);

    print("🔔 Notification permission: ${settings.authorizationStatus}");
  }
}
