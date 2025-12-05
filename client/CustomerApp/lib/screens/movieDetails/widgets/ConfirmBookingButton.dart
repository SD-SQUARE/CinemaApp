import 'package:flutter/material.dart';
import 'package:customerapp/constants/AppColors.dart';

class ConfirmBookingButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const ConfirmBookingButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? AppColors.primaryColor : Colors.grey[700],
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: enabled ? onPressed : null,
        child: const Text(
          "Confirm Booking",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
