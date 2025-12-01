import 'package:customerapp/cubits/SignUp/SignUpCubit.dart';
import 'package:flutter/material.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfirmPasswordField extends StatefulWidget {
  const ConfirmPasswordField({
    super.key,
    required TextEditingController controller,
  });

  @override
  State<ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<ConfirmPasswordField> {
  bool showPassword = true;
  toogleVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: showPassword,
      onChanged: (value) => {
        context.read<SignUpCubit>().updateConfirmPassword(value)
      },
      decoration: _decor("Confirm Password", Icons.lock_outline),
      validator: (value) =>
          value == null || value.isEmpty ? "Confirm your password" : null,
    );
  }

  InputDecoration _decor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primaryColor),
      suffixIcon: IconButton(
        icon: Icon(
          showPassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.primaryColor,
        ),
        onPressed: toogleVisibility,
      ),
      labelStyle: TextStyle(color: AppColors.primaryColor),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
