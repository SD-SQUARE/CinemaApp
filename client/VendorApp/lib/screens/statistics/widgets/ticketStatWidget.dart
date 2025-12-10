import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vendorapp/constants/AppColors.dart';
import 'package:vendorapp/models/TicketSummery.dart';

class TicketStatItem extends StatelessWidget {
  final TicketDetail ticket;

  const TicketStatItem({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      color: AppColors.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: ListTile(
        title: Text(
          ticket.movieName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer: ${ticket.customerName}',
              style: TextStyle(color: AppColors.secondaryTextColor),
            ),
            Text(
              'Showtime: ${dateFormat.format(ticket.showTime)} at ${timeFormat.format(ticket.showTime)}',
              style: TextStyle(color: AppColors.secondaryTextColor),
            ),
          ],
        ),
        trailing: Text(
          'E£ ${ticket.totalPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.accentColor,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
