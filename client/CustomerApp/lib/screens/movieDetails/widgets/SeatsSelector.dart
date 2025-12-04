import 'package:flutter/material.dart';
import 'package:customerapp/constants/AppColors.dart';

class SeatsSelector extends StatelessWidget {
  final Set<int> selectedSeats; // Current user's selected seats
  final Set<int> reservedSeats; // Reserved seats (by other users)

  final bool selectable;
  final ValueChanged<int> onToggleSeat;

  const SeatsSelector({
    super.key,
    required this.selectedSeats,
    required this.reservedSeats,
    required this.onToggleSeat,
    this.selectable = true,
  });

  @override
  Widget build(BuildContext context) {
    const seatSize = 27.0;

    const layout = [
      [1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ];

    int seatIndex = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Seats",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        Column(
          mainAxisSize: MainAxisSize.min,
          children: layout.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((cell) {
                  if (cell == 0) {
                    return const SizedBox(width: seatSize, height: seatSize);
                  }

                  final idx = seatIndex++;
                  final isReserved = reservedSeats.contains(idx);
                  final isSelected = selectedSeats.contains(idx);

                  Color color;
                  if (isReserved) {
                    color = Colors.grey[600]!; // Reserved (gray)
                  } else if (isSelected) {
                    color = AppColors.primaryColor; // Selected (main color)
                  } else {
                    color = Colors.grey[800]!; // Available (dark gray)
                  }

                  return GestureDetector(
                    onTap: (!selectable || isReserved)
                        ? null
                        : () => onToggleSeat(idx), // Toggle on seat tap

                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      width: seatSize,
                      height: seatSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: color,
                        border: Border.all(color: Colors.white24),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
