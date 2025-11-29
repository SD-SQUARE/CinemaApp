import 'package:customerapp/cubits/Login/LoginCubit.dart';
import 'package:customerapp/screens/movieList/MovieList.screen.dart';
import 'package:flutter/material.dart';
import 'package:customerapp/constants/AppColors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const LoginButton({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          // Trigger Cubit / State management here
          print('Login Button Pressed');
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            // Proceed with signup logic
            print('Form is valid. Proceeding with signup...');
            context
                .read<LoginCubit>()
                .loginWithEmailAndPassword()
                .then((_) {
                  print('Login successful!');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login successful!')),
                  );
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    MovieListScreen.routeName,
                    (route) => false,
                  );
                })
                .catchError((error) {
                  print('Login failed: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Login failed: Invalid credentials'),
                    ),
                  );
                });
          }
        },
        child: const Text("Login", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
