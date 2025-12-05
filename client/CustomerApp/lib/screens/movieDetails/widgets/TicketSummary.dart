import 'package:customerapp/constants/AppColors.dart';
import 'package:flutter/material.dart';

class TicketSummary extends StatelessWidget {
  final int seatCount;
  final double pricePerSeat;
  final double totalPrice;
  final Set<int> selectedSeats;

  const TicketSummary({
    Key? key,
    required this.seatCount,
    required this.pricePerSeat,
    required this.totalPrice,
    required this.selectedSeats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Container(
          width:
              MediaQuery.of(context).size.width * 0.85, // 85% of screen width
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ticket Summary",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Seat count and price per seat in one column
              Text(
                "Seats selected: $seatCount",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "Price per seat: \$${pricePerSeat.toStringAsFixed(2)}", // Format to 2 decimal places
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 12),

              // Showing total calculation in a separate row
              Text(
                "$seatCount * \$${pricePerSeat.toStringAsFixed(2)} = \$${totalPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Display selected seats with a nicer design
              if (selectedSeats.isNotEmpty) ...[
                Text(
                  "Selected Seats:",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: selectedSeats.map((seat) {
                    return Chip(
                      label: Text(
                        seat.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.grey,
                    );
                  }).toList(),
                ),
              ] else ...[
                Text(
                  "No seats selected",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
