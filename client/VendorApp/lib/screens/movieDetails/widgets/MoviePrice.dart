import 'package:flutter/material.dart';
import 'package:vendorapp/constants/AppColors.dart';

class MoviePrice extends StatelessWidget {
  final double price;

  const MoviePrice({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Price: ",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "${price.toStringAsFixed(2)} LE",
          style: TextStyle(
            fontSize: 18,
            color: AppColors.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
