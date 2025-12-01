import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendorapp/cubits/movieList/movieListCubit.dart';
import 'package:vendorapp/screens/Home/main.screen.dart';
import 'package:vendorapp/screens/splash/splash.screen.dart';
import 'package:vendorapp/services/notification_service.dart';
import 'package:vendorapp/services/seeding/movie_seeding.dart';
import 'package:vendorapp/services/supabase_client.dart';
import 'package:vendorapp/utils/permission_handler.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services concurrently without blocking the UI thread
  try {
    await Future.wait([
      requestPermissions(),
      NotificationService.init(),
      SupabaseService.init(),
      MovieSeeding.seedMovies(),
    ]);
    print("done");
  } catch (e) {
    print("Error initializing services: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => Movielistcubit())],
      child: MaterialApp(
        title: 'Customer App',
        debugShowCheckedModeBanner:
            false, // Turn off the debug banner for a cleaner UI
        initialRoute: SplashScreen.routeName,
        onGenerateRoute: (settings) {
          late Widget page;
          print("Navigating to: ${settings.name}");

          switch (settings.name) {
            case SplashScreen.routeName:
              page = const SplashScreen();
              break;
            case MainScreen.routeName:
              page = MainScreen();
              break;
            default:
              page = const SplashScreen(); // fallback
          }

          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
