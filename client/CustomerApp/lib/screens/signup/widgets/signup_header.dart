import 'package:flutter/material.dart';
import 'package:customerapp/constants/AppColors.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Join us today!",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Create an account to continue",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
