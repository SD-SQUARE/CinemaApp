import 'package:customerapp/cubits/Login/LoginCubit.dart';
import 'package:customerapp/cubits/SignUp/SignUpCubit.dart';
import 'package:customerapp/cubits/movieDetails/movieDetailsCubit.dart';
import 'package:customerapp/cubits/movieList/movieListCubit.dart';
import 'package:customerapp/models/TicketItem.dart';
import 'package:customerapp/screens/Home/main.screen.dart';
import 'package:customerapp/screens/login/Login.screen.dart';
import 'package:customerapp/screens/movieDetails/MovieDetailsPage.dart';
import 'package:customerapp/screens/movieList/MovieList.screen.dart';
import 'package:customerapp/screens/myTickets/myTickets.screen.dart';
import 'package:customerapp/screens/signup/Signup.screen.dart';
import 'package:customerapp/screens/splash/splash.screen.dart';
import 'package:customerapp/services/supabase_client.dart';
import 'package:customerapp/services/notification_service.dart';
import 'package:customerapp/ticketDetails/TicketDetails.screen.dart';
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
        BlocProvider(create: (context) => Movielistcubit()),
        BlocProvider(create: (context) => MovieDetailsCubit()),
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

            case MainScreen.routeName:
              page = MainScreen();
              break;
            case MovieDetailsPage.routeName:
              final movieId = settings.arguments as String;
              page = MovieDetailsPage(movieId: movieId);
              break;
            case MyTicketsPage.routeName:
              page = MyTicketsPage();
              break;
            case TicketDetailsPage.routeName:
              final args = settings.arguments as TicketItem;
              page = TicketDetailsPage(ticket: args);
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
