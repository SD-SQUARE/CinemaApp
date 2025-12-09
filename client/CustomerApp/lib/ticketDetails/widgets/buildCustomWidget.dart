import 'package:flutter/material.dart';
import 'package:customerapp/constants/AppColors.dart';

Widget buildCustomDetail(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.secondaryTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          maxLines: null,
        ),
      ],
    ),
  );
}
