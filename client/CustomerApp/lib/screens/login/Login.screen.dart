import 'package:customerapp/constants/AppColors.dart';
import 'package:customerapp/constants/AppConstraints.dart';
import 'package:flutter/material.dart';
import 'widgets/login_header.dart';
import 'widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Appconstraints.appPadding),
        child: SizedBox(
          height: Appconstraints.height(context) - kToolbarHeight - 148,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const LoginHeader(),
              const SizedBox(height: 25),
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
