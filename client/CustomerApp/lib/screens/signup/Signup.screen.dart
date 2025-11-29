import 'package:customerapp/constants/AppColors.dart';
import 'package:customerapp/constants/AppConstraints.dart';
import 'package:flutter/material.dart';
import 'widgets/signup_header.dart';
import 'widgets/signup_form.dart';

class SignupScreen extends StatelessWidget {
  static const routeName = '/signup';

  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,

      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Create Account',
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
              const SignupHeader(),
              const SizedBox(height: 25),
              SignupForm(),
            ],
          ),
        ),
      ),
    );
  }
}
