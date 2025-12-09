import 'package:customerapp/cubits/SignUp/SignUpCubit.dart';
import 'package:customerapp/screens/Home/main.screen.dart';
import 'package:flutter/material.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const SignupButton({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          // Trigger Cubit / State management here
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            // Proceed with signup logic
            context
                .read<SignUpCubit>()
                .signUpWithEmailAndPassword()
                .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signup successful!')),
                  );
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    MainScreen.routeName,
                    (route) => false,
                  );
                })
                .catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Signup failed: $error')),
                  );
                });
          }
        },
        child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
