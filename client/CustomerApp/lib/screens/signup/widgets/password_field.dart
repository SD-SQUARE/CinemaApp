import 'package:customerapp/cubits/SignUp/SignUpCubit.dart';
import 'package:customerapp/models/SignUpUser.modal.dart';
import 'package:flutter/material.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({super.key, required TextEditingController controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
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
      onChanged: (value) {
        context.read<SignUpCubit>().updatePassword(value);
      },
      decoration: _decor("Password", Icons.lock),
      validator: (value) => value != null && SignUpUser.isValidPassword(value)
          ? null
          : "Password must be at least 8 characters and 1 uppercase letter and 1 lowercase letter and 1 number",
    );
  }

  InputDecoration _decor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.accentColor),
      errorMaxLines: 4,
      suffixIcon: IconButton(
        icon: Icon(
          showPassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.accentColor,
        ),
        onPressed: toogleVisibility,
      ),
      labelStyle: TextStyle(color: AppColors.accentColor),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.accentColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.accentColor),
        borderRadius: BorderRadius.circular(12),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
