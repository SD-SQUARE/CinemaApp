import 'package:flutter/material.dart';
import 'package:vendorapp/constants/AppColors.dart';
import 'package:vendorapp/screens/addMovie/AddMovie.dart';
import 'package:vendorapp/screens/navigationBar/navigationBar.dart';

class MainScreen extends StatelessWidget {
  static const routeName = '/main-screen';

  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const NavigationBarSection(),
          Positioned(
            right: 20.0,
            bottom: 120.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AddMoviePage.routeName);
              },
              child: const Icon(Icons.add, color: AppColors.textColor),
              backgroundColor: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
