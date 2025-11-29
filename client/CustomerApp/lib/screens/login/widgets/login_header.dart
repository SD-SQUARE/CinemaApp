import 'package:flutter/material.dart';
import 'package:customerapp/constants/AppColors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Welcome Back!",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Login to continue",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
