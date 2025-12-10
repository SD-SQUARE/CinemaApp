import 'package:customerapp/cubits/SignUp/SignUpCubit.dart';
import 'package:flutter/material.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NameField extends StatelessWidget {
  const NameField({super.key, required TextEditingController controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: _decor("Name", Icons.person),
      onChanged: (value) {
        context.read<SignUpCubit>().updateName( value);
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter your name' : null,
    );
  }

  InputDecoration _decor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.accentColor),
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
