import 'package:customerapp/cubits/Login/LoginCubit.dart';
import 'package:customerapp/cubits/SignUp/SignUpCubit.dart';
import 'package:customerapp/screens/login/Login.screen.dart';
import 'package:customerapp/screens/movieList/MovieList.screen.dart';
import 'package:customerapp/screens/signup/Signup.screen.dart';
import 'package:customerapp/screens/splash/splash.screen.dart';
import 'package:customerapp/services/supabase_client.dart';
import 'package:customerapp/services/notification_service.dart';
import 'package:customerapp/utils/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await requestPermissions();
  await NotificationService.init();
  await SupabaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SignUpCubit()),
        BlocProvider(create: (context) => LoginCubit()),
      ],
      child: MaterialApp(
        title: 'Customer App',
        debugShowCheckedModeBanner: false,
        initialRoute: SplashScreen.routeName,
        onGenerateRoute: (settings) {
          late Widget page;

          switch (settings.name) {
            case SplashScreen.routeName:
              page = const SplashScreen();
              break;
            case LoginScreen.routeName:
              page = const LoginScreen();
              break;
            case SignupScreen.routeName:
              page = const SignupScreen();
              break;
            case MovieListScreen.routeName:
              page = MovieListScreen();
              break;
            default:
              page = const SplashScreen(); // fallback
          }

          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  // Slide from right transition
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: Curves.easeInOut));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),
    );
  }
}
