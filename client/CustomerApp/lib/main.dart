
import 'package:customerapp/screens/login/Login.screen.dart';
import 'package:customerapp/screens/movieList/MovieList.screen.dart';
import 'package:customerapp/screens/signup/Signup.screen.dart';
import 'package:customerapp/screens/splash/splash.screen.dart';
import 'package:flutter/material.dart';
import 'package:customerapp/services/notification_service.dart';
import 'package:customerapp/utils/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await requestPermissions();
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer App',
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        SignupScreen.routeName: (context) => const SignupScreen(),
        MovieListScreen.routeName: (context) => const MovieListScreen(),
      },
    );
  }
}
