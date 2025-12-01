import 'package:customerapp/screens/login/Login.screen.dart';
import 'package:customerapp/screens/signup/widgets/confirm_password_field.dart';
import 'package:customerapp/screens/signup/widgets/email_field.dart';
import 'package:customerapp/screens/signup/widgets/name_field.dart';
import 'package:customerapp/screens/signup/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'signup_button.dart';

class SignupForm extends StatefulWidget {

  SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Form(
        key: _formKey,
        child: Column(
          children: [
            NameField(controller: nameController),
            const SizedBox(height: 16),
            EmailField(controller: emailController),
            const SizedBox(height: 16),
            PasswordField(controller: passwordController),
            const SizedBox(height: 16),
            ConfirmPasswordField(controller: confirmPasswordController),
            const SizedBox(height: 24),
            SignupButton(formKey: _formKey),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? '),
                InkWell(
                  onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    LoginScreen.routeName,
                    (route) => false
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
