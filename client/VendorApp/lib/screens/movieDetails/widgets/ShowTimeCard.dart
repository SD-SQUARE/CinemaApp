import 'package:flutter/material.dart';
import 'package:vendorapp/constants/AppColors.dart';
import 'package:vendorapp/models/TimeShow.dart';
import 'package:vendorapp/utils/DateHelper.dart';

class ShowTimeCard extends StatelessWidget {
  final TimeShow timeShow;
  final bool isSelected;

  final bool selectable;

  final VoidCallback? onTap;

  const ShowTimeCard({
    super.key,
    required this.timeShow,
    required this.isSelected,
    this.selectable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[850]!;
    final highlightColor = AppColors.primaryColor;

    return GestureDetector(
      onTap: selectable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? highlightColor.withOpacity(0.2) : baseColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? highlightColor : Colors.white24,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event,
              size: 16,
              color: isSelected ? highlightColor : Colors.white70,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Datehelper.dateLabel(timeShow.time),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                Text(
                  Datehelper.timeLabel(timeShow.time),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
