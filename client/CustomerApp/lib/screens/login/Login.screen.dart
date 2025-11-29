
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  
  static final routeName = '/login';
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Text('Welcome to the Login Screen'),
      ),
    );
  }
}