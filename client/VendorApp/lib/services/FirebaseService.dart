import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vendorapp/screens/movieDetails/MovieDetailsPage.dart';
import 'package:vendorapp/main.dart';

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

  void setupNotificationNavigation() {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("#FCM 🔵 Message clicked!: ${message.data.toString()}");
    _navigateToScreen(message.data);
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("#FCM 🟢 Foreground Message clicked!: ${message.data.toString()}");
    _navigateToScreen(message.data);
  });
}

void _navigateToScreen(Map<String, dynamic> data) {
  final String? navigateTo = data['navigate_to'];
  final String? movieId = data['movie_id'];

  if (navigateTo == 'movie-details' && movieId != null) {
    navigatorKey.currentState!.pushNamedAndRemoveUntil(MovieDetailsPage.routeName, (route) => false, arguments: movieId);
  }
}

}
