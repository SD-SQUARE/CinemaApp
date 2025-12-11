import 'package:flutter/material.dart';
import 'package:vendorapp/constants/AppColors.dart';

class SummaryCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: AppColors.cardColor,
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),

            border: Border(left: BorderSide(color: color, width: 5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 30, color: color),
                    SizedBox(width: icon == Icons.currency_pound ? 0 : 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
