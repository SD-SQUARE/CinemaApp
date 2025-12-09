import 'dart:async';

import 'package:customerapp/constants/AppAssets.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:customerapp/constants/AppConstraints.dart';
import 'package:customerapp/screens/Home/main.screen.dart';
import 'package:customerapp/screens/login/Login.screen.dart';
import 'package:customerapp/screens/splash/controller/splash_controller.dart';
import 'package:customerapp/screens/splash/widgets/SplashAnimatedText.dart';
import 'package:customerapp/services/supabase_client.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  late Timer timer;
  int index = 0;
  String text = SplashLogic.getWord(0);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);
    _slide = Tween<Offset>(
      begin: const Offset(0, .5),
      end: Offset.zero,
    ).animate(_controller);

    _controller.forward();

    timer = Timer.periodic(const Duration(seconds: 1, milliseconds: 800), (_) {
      _controller.reverse().then((_) {
        setState(() {
          index++;
          text = SplashLogic.getWord(index);
        });
        _controller.forward();
      });
    });

    Future.delayed(
      const Duration(seconds: 5, milliseconds: 810, microseconds: 2000),
      checkUserAndNavigate,
    );
  }

  Future<void> checkUserAndNavigate() async {
    if (!mounted) return;

    final session = SupabaseService.client.auth.currentSession;

    // You can also use Supabase.instance.client.auth.currentUser
    final user = session?.user;

    Navigator.of(context).pushNamedAndRemoveUntil(
      user != null ? MainScreen.routeName : LoginScreen.routeName,
      (route) => false,
    );
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
            colors: [AppColors.accentColor, AppColors.primaryColor],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(AppAssets.splashAnimation, height: 500),
            SplashAnimatedText(
              controller: _controller,
              fade: _fade,
              slide: _slide,
              text: text,
            ),
          ],
        ),
      ),
    );
  }
}
