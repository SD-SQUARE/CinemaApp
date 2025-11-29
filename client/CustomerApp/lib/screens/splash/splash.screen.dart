import 'dart:async';
import 'package:customerapp/constants/AppAssets.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:customerapp/constants/AppConstraints.dart';
import 'package:customerapp/screens/login/Login.screen.dart';
import 'package:customerapp/screens/movieList/MovieList.screen.dart';
import 'package:customerapp/services/supabase_client.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  static final routeName = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final List<String> splashWords = [
    "Welcome to Cinmeco",
    "Thank You for Choosing Us",
    "Verifying Your Account",
  ];

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late Timer timer;

  String words = "";
  int index = 0;

  @override
  void initState() {
    super.initState();

    /// MUST be initialized BEFORE build() runs
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(_controller);

    words = splashWords.first;
    _controller.forward();

    timer = Timer.periodic(const Duration(seconds: 1, milliseconds: 500), (_) {
      if (!mounted) return;

      /// Fade-out -> change text -> fade-in
      _controller.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          index++;
          words = splashWords[index % splashWords.length];
        });
        _controller.forward();
      });
    });

    // Navigate after 3 seconds
    if (SupabaseService.client.auth.currentUser != null) {
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, MovieListScreen.routeName);
      });
    } else {
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Appconstraints.height(context),
        width: Appconstraints.width(context),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryColor, AppColors.secondaryColor],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(AppAssets.splashAnimation, height: 400),

            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Opacity(
                opacity: _fadeAnimation.value,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    words,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
