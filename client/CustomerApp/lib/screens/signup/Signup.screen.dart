

import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {

  static final routeName = '/signup';
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: Text('Signup Screen Content Here'),
      ),
    );
  }
}